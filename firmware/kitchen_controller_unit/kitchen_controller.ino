// ================================================================
// SmartNest Water Tank — KITCHEN CONTROLLER UNIT
// ESP32 + NRF24L01 PA+LNA + SSD1306 OLED + Relay + 1 Button
// Receives level from tank unit, controls pump, shows on OLED
// App control via HTTP
// ================================================================

#include <SPI.h>
#include <RF24.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <WiFi.h>
#include <WebServer.h>
#include <Preferences.h>
#include <ArduinoJson.h>

// ===== NRF24 pins =====
// CE  → GPIO 4
// CSN → GPIO 5
RF24 radio(4, 5);
const byte address[6] = "TANK1";

// ===== OLED =====
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

// ===== Other pins =====
#define RELAY_PIN  14   // Pump relay
#define BUTTON_PIN 13   // Mode button
#define LED_PIN    2    // Built-in LED

// ===== Settings =====
#define AUTO_ON_LEVEL  20   // Pump ON when level below this %
#define AUTO_OFF_LEVEL 90   // Pump OFF when level above this %

// ===== WiFi provisioning =====
// Default AP credentials (for setup)
const char* AP_SSID = "SmartNest-Tank";
const char* AP_PASS = "smartnest123";

// ===== State =====
struct TankData {
  uint8_t  level;
  float    distanceCm;
  bool     sensorOk;
  uint32_t timestamp;
};

TankData tankData;
bool     pumpOn      = false;
bool     autoMode    = true;   // true=auto, false=manual
bool     wifiOk      = false;
bool     dataReceived = false;
unsigned long lastDataTime = 0;
unsigned long lastOledUpdate = 0;
unsigned long lastButtonTime = 0;
bool buttonPressed = false;
int oledPage = 0; // 0=level, 1=pump, 2=mode, 3=wifi

Preferences prefs;
WebServer server(80);
String savedSSID = "";
String savedPass = "";

// ================================================================
// PUMP CONTROL
// ================================================================
void setPump(bool on) {
  pumpOn = on;
  digitalWrite(RELAY_PIN, on ? HIGH : LOW);
  Serial.printf("Pump: %s\n", on ? "ON" : "OFF");
}

void autoControl() {
  if (!autoMode || !dataReceived) return;
  if (tankData.level <= AUTO_ON_LEVEL && !pumpOn) {
    setPump(true);
    Serial.println("AUTO: Pump ON (low water)");
  } else if (tankData.level >= AUTO_OFF_LEVEL && pumpOn) {
    setPump(false);
    Serial.println("AUTO: Pump OFF (tank full)");
  }
}

// ================================================================
// OLED DISPLAY
// ================================================================
void drawLevelBar(int level) {
  int barWidth = map(level, 0, 100, 0, 100);
  display.drawRect(14, 40, 100, 16, WHITE);
  display.fillRect(14, 40, barWidth, 16, WHITE);
}

void updateOled() {
  display.clearDisplay();
  display.setTextColor(WHITE);

  bool noData = (millis() - lastDataTime > 10000) || !dataReceived;

  if (oledPage == 0) {
    // === Page 1: Water level ===
    display.setTextSize(1);
    display.setCursor(0, 0);
    display.print("SmartNest Water");

    if (noData) {
      display.setTextSize(2);
      display.setCursor(20, 22);
      display.print("NO DATA");
    } else {
      display.setTextSize(3);
      String lvl = String(tankData.level) + "%";
      int x = (128 - (lvl.length() * 18)) / 2;
      display.setCursor(x, 16);
      display.print(lvl);
      drawLevelBar(tankData.level);

      // Status text
      display.setTextSize(1);
      display.setCursor(0, 57);
      if (tankData.level < 20)      display.print("!! LOW WATER !!");
      else if (tankData.level > 90) display.print("Tank full");
      else                           display.print("Level normal");
    }

  } else if (oledPage == 1) {
    // === Page 2: Pump status ===
    display.setTextSize(1);
    display.setCursor(0, 0);
    display.print("Pump Status");

    display.setTextSize(3);
    display.setCursor(20, 20);
    display.print(pumpOn ? "ON" : "OFF");

    display.setTextSize(1);
    display.setCursor(0, 50);
    display.printf("Mode: %s", autoMode ? "AUTO" : "MANUAL");

    display.setCursor(70, 50);
    display.printf("Lv:%d%%", tankData.level);

  } else if (oledPage == 2) {
    // === Page 3: Mode + control ===
    display.setTextSize(1);
    display.setCursor(0, 0);
    display.print("Control Mode");

    display.setTextSize(2);
    display.setCursor(10, 18);
    display.print(autoMode ? "AUTO" : "MANUAL");

    display.setTextSize(1);
    display.setCursor(0, 40);
    if (autoMode) {
      display.printf("ON<%d%%  OFF>%d%%", AUTO_ON_LEVEL, AUTO_OFF_LEVEL);
    } else {
      display.print("App/Button control");
    }
    display.setCursor(0, 52);
    display.print("Hold btn: toggle mode");

  } else if (oledPage == 3) {
    // === Page 4: WiFi + IP ===
    display.setTextSize(1);
    display.setCursor(0, 0);
    display.print("WiFi Status");

    display.setCursor(0, 16);
    if (wifiOk) {
      display.print("Connected:");
      display.setCursor(0, 28);
      display.print(savedSSID.substring(0, 18));
      display.setCursor(0, 42);
      display.print("IP:");
      display.print(WiFi.localIP().toString());
      display.setCursor(0, 54);
      display.print("smartnest-tank.local");
    } else {
      display.print("Setup mode:");
      display.setCursor(0, 30);
      display.print("WiFi: SmartNest-Tank");
      display.setCursor(0, 44);
      display.print("Pass: smartnest123");
    }
  }

  display.display();
}

// ================================================================
// BUTTON HANDLER
// Single tap → cycle OLED pages
// Hold 2s   → toggle Auto/Manual mode
// ================================================================
void handleButton() {
  bool pressed = (digitalRead(BUTTON_PIN) == LOW);

  if (pressed && !buttonPressed) {
    buttonPressed = true;
    lastButtonTime = millis();
  }

  if (!pressed && buttonPressed) {
    buttonPressed = false;
    unsigned long held = millis() - lastButtonTime;

    if (held > 2000) {
      // Long press → toggle mode
      autoMode = !autoMode;
      prefs.putBool("autoMode", autoMode);
      Serial.printf("Mode changed: %s\n", autoMode ? "AUTO" : "MANUAL");
      oledPage = 2; // Show mode page
    } else if (held > 50) {
      // Short press → next page
      oledPage = (oledPage + 1) % 4;
    }
  }
}

// ================================================================
// HTTP SERVER
// ================================================================
void setupHttpServer() {
  // Get status
  server.on("/status", HTTP_GET, []() {
    StaticJsonDocument<200> doc;
    doc["level"]     = tankData.level;
    doc["pumpOn"]    = pumpOn;
    doc["autoMode"]  = autoMode;
    doc["sensorOk"]  = tankData.sensorOk;
    doc["dataAge"]   = (millis() - lastDataTime) / 1000;
    doc["wifiOk"]    = wifiOk;
    String out;
    serializeJson(doc, out);
    server.send(200, "application/json", out);
  });

  // Ping
  server.on("/ping", HTTP_GET, []() {
    server.send(200, "application/json", "{\"status\":\"ok\",\"device\":\"smartnest-tank\"}");
  });

  // Control pump / mode
  server.on("/control", HTTP_POST, []() {
    String body = server.arg("plain");
    StaticJsonDocument<200> doc;
    if (!deserializeJson(doc, body)) {
      if (!doc["pumpOn"].isNull() && !autoMode) {
        setPump(doc["pumpOn"].as<bool>());
      }
      if (!doc["autoMode"].isNull()) {
        autoMode = doc["autoMode"].as<bool>();
        prefs.putBool("autoMode", autoMode);
      }
    }
    server.send(200, "application/json", "{\"status\":\"ok\"}");
  });

  // WiFi provisioning — receive credentials from app
  server.on("/wifi-setup", HTTP_POST, []() {
    String body = server.arg("plain");
    StaticJsonDocument<200> doc;
    if (!deserializeJson(doc, body)) {
      String ssid = doc["ssid"].as<String>();
      String pass = doc["password"].as<String>();
      if (ssid.length() > 0) {
        prefs.putString("ssid", ssid);
        prefs.putString("pass", pass);
        server.send(200, "application/json", "{\"status\":\"ok\",\"msg\":\"Saved! Rebooting...\"}");
        delay(1000);
        ESP.restart();
      }
    }
    server.send(400, "application/json", "{\"status\":\"error\"}");
  });

  server.begin();
}

// ================================================================
// WIFI SETUP
// ================================================================
void setupWifi() {
  prefs.begin("smartnest", false);
  savedSSID = prefs.getString("ssid", "");
  savedPass = prefs.getString("pass", "");
  autoMode  = prefs.getBool("autoMode", true);

  if (savedSSID.length() > 0) {
    Serial.printf("Connecting to WiFi: %s\n", savedSSID.c_str());
    WiFi.begin(savedSSID.c_str(), savedPass.c_str());

    int tries = 0;
    while (WiFi.status() != WL_CONNECTED && tries < 20) {
      delay(500);
      Serial.print(".");
      tries++;
    }

    if (WiFi.status() == WL_CONNECTED) {
      wifiOk = true;
      Serial.println("\nWiFi connected!");
      Serial.println("IP: " + WiFi.localIP().toString());

      // mDNS — smartnest-tank.local
      // mdns.begin("smartnest-tank"); // add mDNS library if needed
    } else {
      Serial.println("\nWiFi failed! Starting AP mode...");
      WiFi.mode(WIFI_AP);
      WiFi.softAP(AP_SSID, AP_PASS);
    }
  } else {
    Serial.println("No WiFi saved. Starting AP mode...");
    WiFi.mode(WIFI_AP);
    WiFi.softAP(AP_SSID, AP_PASS);
    Serial.printf("AP: %s / %s\n", AP_SSID, AP_PASS);
  }
}

// ================================================================
// SETUP
// ================================================================
void setup() {
  Serial.begin(115200);
  Serial.println("SmartNest Kitchen Controller starting...");

  pinMode(RELAY_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW);

  // OLED
  Wire.begin(21, 22); // SDA=21, SCL=22
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("OLED not found!");
  } else {
    display.clearDisplay();
    display.setTextSize(1);
    display.setTextColor(WHITE);
    display.setCursor(20, 20);
    display.print("SmartNest");
    display.setCursor(10, 36);
    display.print("Water Controller");
    display.display();
    delay(1500);
  }

  // NRF24
  if (!radio.begin()) {
    Serial.println("NRF24 init failed!");
  } else {
    radio.setPALevel(RF24_PA_MAX);
    radio.setDataRate(RF24_250KBPS);
    radio.setChannel(108);
    radio.openReadingPipe(1, address);
    radio.startListening(); // Receiver mode
    Serial.println("NRF24 ready! Listening for tank data...");
  }

  // WiFi + HTTP
  setupWifi();
  setupHttpServer();

  Serial.println("Setup complete!");
}

// ================================================================
// LOOP
// ================================================================
void loop() {
  server.handleClient();
  handleButton();

  // Receive NRF24 data from tank
  if (radio.available()) {
    radio.read(&tankData, sizeof(tankData));
    dataReceived = true;
    lastDataTime = millis();

    Serial.printf("Tank: Level=%d%% Dist=%.1fcm SensorOK=%d\n",
      tankData.level, tankData.distanceCm, tankData.sensorOk);

    // Auto pump control
    autoControl();

    // Blink LED on receive
    digitalWrite(LED_PIN, HIGH);
    delay(10);
    digitalWrite(LED_PIN, LOW);
  }

  // Update OLED every 500ms
  if (millis() - lastOledUpdate > 500) {
    updateOled();
    lastOledUpdate = millis();
  }

  // Auto cycle OLED pages every 5s (only page 0 and 1)
  static unsigned long lastPageChange = 0;
  if (millis() - lastPageChange > 5000 && !buttonPressed) {
    if (oledPage == 0) oledPage = 1;
    else if (oledPage == 1) oledPage = 0;
    lastPageChange = millis();
  }
}
