// ============================================================
// SmartNest Water Tank — CONTROLLER UNIT (Kitchen side)
// Hardware: ESP32 + NRF24L01 PA+LNA + SSD1306 OLED +
//           1 button + Relay + WiFi HTTP server
// ============================================================
#include <SPI.h>
#include <RF24.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <Preferences.h>

// ===== WiFi Provisioning =====
// First boot: creates "SmartNest-Tank" hotspot
// App connects and sends WiFi credentials
// After that: connects to home WiFi automatically

// ===== PIN CONFIG =====
// NRF24
#define NRF_CE    4
#define NRF_CSN   5
// OLED (I2C)
#define OLED_SDA  21
#define OLED_SCL  22
// Button
#define BTN_PIN   15   // single button — press to toggle Auto/Manual
// Relay (pump)
#define RELAY_PIN 27   // LOW = pump ON (active low relay)

// ===== OLED =====
#define SCREEN_W  128
#define SCREEN_H  64
Adafruit_SSD1306 display(SCREEN_W, SCREEN_H, &Wire, -1);

// ===== NRF24 =====
RF24 radio(NRF_CE, NRF_CSN);
const byte address[6] = "TANK1";

struct TankData {
  int   levelPercent;
  float distanceCm;
  bool  sensorOk;
};

// ===== State =====
bool      autoMode       = true;   // true=auto, false=manual
bool      pumpOn         = false;
int       tankLevel      = 0;
bool      sensorOnline   = false;
unsigned long lastReceived = 0;
unsigned long lastOledUpdate = 0;
int       oledPage       = 0;      // 0=level, 1=pump, 2=mode, 3=wifi

// Auto mode thresholds
#define AUTO_ON_BELOW   20   // pump ON when level < 20%
#define AUTO_OFF_ABOVE  90   // pump OFF when level > 90%

// WiFi + HTTP
WebServer server(80);
Preferences prefs;
String savedSSID = "";
String savedPass = "";
bool   wifiConnected = false;
bool   apMode        = false;

// ===== BUTTON =====
unsigned long lastBtnPress = 0;

void setPump(bool on) {
  pumpOn = on;
  digitalWrite(RELAY_PIN, on ? LOW : HIGH); // active-low relay
}

// ============================================================
// OLED DISPLAY
// ============================================================
void oledShowLevel() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  
  // Title
  display.setCursor(0, 0);
  display.println("WATER TANK");
  display.drawLine(0, 10, 128, 10, SSD1306_WHITE);
  
  if (!sensorOnline) {
    display.setCursor(0, 20);
    display.println("Sensor offline!");
    display.setCursor(0, 35);
    display.println("Check tank unit");
  } else {
    // Level % — big text
    display.setTextSize(2);
    display.setCursor(0, 16);
    display.print(tankLevel);
    display.print("%");
    
    // Bar graph
    display.setTextSize(1);
    int barW = map(tankLevel, 0, 100, 0, 100);
    display.drawRect(0, 42, 102, 12, SSD1306_WHITE);
    display.fillRect(0, 42, barW, 12, SSD1306_WHITE);
    
    // Status text
    display.setCursor(106, 44);
    if (tankLevel <= 20)      display.print("LOW");
    else if (tankLevel >= 90) display.print("FULL");
    else                      display.print("OK");
  }
  
  display.display();
}

void oledShowPump() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println("PUMP STATUS");
  display.drawLine(0, 10, 128, 10, SSD1306_WHITE);
  
  display.setTextSize(2);
  display.setCursor(0, 20);
  display.println(pumpOn ? "ON" : "OFF");
  
  display.setTextSize(1);
  display.setCursor(0, 48);
  display.print("Mode: ");
  display.print(autoMode ? "AUTO" : "MANUAL");
  display.display();
}

void oledShowMode() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println("CONTROL MODE");
  display.drawLine(0, 10, 128, 10, SSD1306_WHITE);
  
  display.setTextSize(2);
  display.setCursor(0, 18);
  display.println(autoMode ? "AUTO" : "MANUAL");
  
  display.setTextSize(1);
  display.setCursor(0, 45);
  if (autoMode) {
    display.print("ON<");
    display.print(AUTO_ON_BELOW);
    display.print("% OFF>");
    display.print(AUTO_OFF_ABOVE);
    display.print("%");
  } else {
    display.println("Press btn to");
    display.println("control pump");
  }
  display.display();
}

void oledShowWifi() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println("WIFI STATUS");
  display.drawLine(0, 10, 128, 10, SSD1306_WHITE);
  
  display.setCursor(0, 14);
  if (apMode) {
    display.println("Setup mode:");
    display.println("SmartNest-Tank");
    display.println("192.168.4.1");
    display.println("Open SmartNest app");
  } else if (wifiConnected) {
    display.print("Connected:");
    display.println(savedSSID);
    display.print("IP: ");
    display.println(WiFi.localIP().toString());
  } else {
    display.println("Not connected");
    display.println("Hold button 3s");
    display.println("to reset WiFi");
  }
  display.display();
}

void updateOled() {
  switch (oledPage) {
    case 0: oledShowLevel(); break;
    case 1: oledShowPump();  break;
    case 2: oledShowMode();  break;
    case 3: oledShowWifi();  break;
  }
}

// ============================================================
// WIFI PROVISIONING
// ============================================================
void startAPMode() {
  apMode = true;
  WiFi.softAP("SmartNest-Tank", "12345678");
  Serial.println("AP mode: SmartNest-Tank");
  Serial.println("IP: " + WiFi.softAPIP().toString());
  
  // Provisioning endpoint
  server.on("/provision", HTTP_POST, []() {
    String body = server.arg("plain");
    StaticJsonDocument<200> doc;
    if (deserializeJson(doc, body)) {
      server.send(400, "text/plain", "Bad JSON");
      return;
    }
    String ssid = doc["ssid"] | "";
    String pass = doc["password"] | "";
    if (ssid.isEmpty()) {
      server.send(400, "text/plain", "SSID required");
      return;
    }
    prefs.begin("smartnest", false);
    prefs.putString("ssid", ssid);
    prefs.putString("pass", pass);
    prefs.end();
    server.send(200, "application/json", "{\"status\":\"ok\",\"message\":\"Saved! Rebooting...\"}");
    delay(1000);
    ESP.restart();
  });
  
  server.on("/ping", HTTP_GET, []() {
    server.send(200, "application/json", "{\"device\":\"SmartNest-Tank\",\"mode\":\"setup\"}");
  });
  
  server.begin();
}

bool connectWifi() {
  if (savedSSID.isEmpty()) return false;
  WiFi.begin(savedSSID.c_str(), savedPass.c_str());
  Serial.print("Connecting to " + savedSSID);
  int tries = 0;
  while (WiFi.status() != WL_CONNECTED && tries < 20) {
    delay(500); Serial.print("."); tries++;
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi OK: " + WiFi.localIP().toString());
    return true;
  }
  return false;
}

// ============================================================
// HTTP API (after WiFi connected)
// ============================================================
void setupHttpRoutes() {
  // Get current status
  server.on("/status", HTTP_GET, []() {
    StaticJsonDocument<200> doc;
    doc["level"]     = tankLevel;
    doc["pump"]      = pumpOn;
    doc["auto"]      = autoMode;
    doc["online"]    = sensorOnline;
    doc["ip"]        = WiFi.localIP().toString();
    String out;
    serializeJson(doc, out);
    server.send(200, "application/json", out);
  });
  
  // Control pump / mode
  server.on("/control", HTTP_POST, []() {
    String body = server.arg("plain");
    StaticJsonDocument<200> doc;
    if (deserializeJson(doc, body)) {
      server.send(400, "text/plain", "Bad JSON");
      return;
    }
    if (!doc["auto"].isNull())      autoMode = doc["auto"].as<bool>();
    if (!doc["pump"].isNull() && !autoMode) setPump(doc["pump"].as<bool>());
    server.send(200, "application/json", "{\"status\":\"ok\"}");
  });
  
  server.on("/ping", HTTP_GET, []() {
    server.send(200, "application/json", "{\"device\":\"SmartNest-Tank\",\"level\":" + String(tankLevel) + "}");
  });
  
  server.begin();
}

// ============================================================
// SETUP
// ============================================================
void setup() {
  Serial.begin(115200);
  
  // Pins
  pinMode(BTN_PIN, INPUT_PULLUP);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH); // pump OFF initially
  
  // OLED
  Wire.begin(OLED_SDA, OLED_SCL);
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("OLED not found!");
  }
  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.println("SmartNest Tank");
  display.println("Starting...");
  display.display();
  
  // NRF24
  if (!radio.begin()) {
    Serial.println("NRF24 not found!");
    display.setCursor(0, 20);
    display.println("NRF24 ERROR!");
    display.display();
  } else {
    radio.setPALevel(RF24_PA_MAX);
    radio.setDataRate(RF24_250KBPS);
    radio.setChannel(108);
    radio.openReadingPipe(0, address);
    radio.startListening(); // receiver mode
    Serial.println("NRF24 ready — listening");
  }
  
  // Load saved WiFi
  prefs.begin("smartnest", true);
  savedSSID = prefs.getString("ssid", "");
  savedPass = prefs.getString("pass", "");
  prefs.end();
  
  // WiFi connect or AP mode
  if (!savedSSID.isEmpty()) {
    wifiConnected = connectWifi();
    if (wifiConnected) {
      setupHttpRoutes();
    } else {
      startAPMode(); // saved creds failed — go to setup
    }
  } else {
    startAPMode(); // no creds — go to setup
  }
  
  Serial.println("Controller unit ready!");
}

// ============================================================
// LOOP
// ============================================================
void loop() {
  server.handleClient();
  
  // ── Receive NRF24 data ──
  if (radio.available()) {
    TankData data;
    radio.read(&data, sizeof(data));
    lastReceived = millis();
    sensorOnline = data.sensorOk;
    if (data.sensorOk) {
      tankLevel = data.levelPercent;
      Serial.println("Level: " + String(tankLevel) + "%");
      
      // Auto mode logic
      if (autoMode) {
        if (tankLevel <= AUTO_ON_BELOW && !pumpOn) {
          setPump(true);
          Serial.println("AUTO: Pump ON (level low)");
        } else if (tankLevel >= AUTO_OFF_ABOVE && pumpOn) {
          setPump(false);
          Serial.println("AUTO: Pump OFF (tank full)");
        }
      }
    }
  }
  
  // ── Sensor timeout ──
  if (millis() - lastReceived > 10000) {
    sensorOnline = false; // no data for 10s = offline
  }
  
  // ── Button handling ──
  if (digitalRead(BTN_PIN) == LOW) {
    if (millis() - lastBtnPress > 300) { // debounce
      lastBtnPress = millis();
      
      if (autoMode) {
        // Switch to manual
        autoMode = false;
        Serial.println("Mode: MANUAL");
      } else {
        // In manual: short press = toggle pump
        // Long press (3s) handled below for WiFi reset
        setPump(!pumpOn);
        Serial.println("Manual pump: " + String(pumpOn ? "ON" : "OFF"));
      }
      
      // Cycle OLED page on button press
      oledPage = (oledPage + 1) % 4;
    }
  }
  
  // ── Long press (3s) = reset WiFi ──
  static unsigned long btnHoldStart = 0;
  if (digitalRead(BTN_PIN) == LOW) {
    if (btnHoldStart == 0) btnHoldStart = millis();
    if (millis() - btnHoldStart > 3000) {
      Serial.println("WiFi reset!");
      prefs.begin("smartnest", false);
      prefs.clear();
      prefs.end();
      delay(500);
      ESP.restart();
    }
  } else {
    btnHoldStart = 0;
  }
  
  // ── OLED update every 2s ──
  if (millis() - lastOledUpdate > 2000) {
    lastOledUpdate = millis();
    updateOled();
  }
}
