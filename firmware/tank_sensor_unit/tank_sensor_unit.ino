// ============================================================
// SmartNest Water Tank — SENSOR UNIT (Tank side)
// Hardware: ESP32 + HC-SR04 + NRF24L01+ PA+LNA
// ============================================================
#include <SPI.h>
#include <RF24.h>

// ===== NRF24L01 pins (ESP32) =====
// CE  → GPIO 4
// CSN → GPIO 5
// SCK → GPIO 18
// MOSI→ GPIO 23
// MISO→ GPIO 19
RF24 radio(4, 5);  // CE, CSN

// ===== HC-SR04 pins =====
#define TRIG_PIN  25
#define ECHO_PIN  26

// ===== Tank config =====
#define TANK_HEIGHT_CM  100  // CHANGE: your tank height in cm
#define SENSOR_OFFSET   5    // sensor to water surface when full (cm)

// ===== NRF24 address =====
const byte address[6] = "TANK1";

// Data packet to send
struct TankData {
  int   levelPercent;   // 0-100%
  float distanceCm;     // raw sensor reading
  bool  sensorOk;       // sensor working?
};

void setup() {
  Serial.begin(115200);
  
  // HC-SR04 setup
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
  // NRF24 setup
  if (!radio.begin()) {
    Serial.println("NRF24 not found! Check wiring.");
    while (1) delay(1000);
  }
  
  radio.setPALevel(RF24_PA_MAX);     // max power for PA+LNA module
  radio.setDataRate(RF24_250KBPS);   // slow = better range
  radio.setChannel(108);             // channel 108 (above WiFi range)
  radio.openWritingPipe(address);
  radio.stopListening();             // transmitter mode
  
  Serial.println("Tank Sensor Unit ready!");
  Serial.println("Tank height: " + String(TANK_HEIGHT_CM) + " cm");
}

float readDistance() {
  // Trigger
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  // Read echo (timeout 30ms)
  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  if (duration == 0) return -1; // timeout = error
  
  float distance = duration * 0.034 / 2.0;
  return distance;
}

int calculateLevel(float distanceCm) {
  // distance = how far sensor is from water surface
  // when full: distance = SENSOR_OFFSET
  // when empty: distance = TANK_HEIGHT_CM
  float waterDepth = TANK_HEIGHT_CM - distanceCm;
  float usableDepth = TANK_HEIGHT_CM - SENSOR_OFFSET;
  int percent = (waterDepth / usableDepth) * 100;
  return constrain(percent, 0, 100);
}

void loop() {
  TankData data;
  
  // Take 3 readings and average for accuracy
  float total = 0;
  int validReadings = 0;
  for (int i = 0; i < 3; i++) {
    float d = readDistance();
    if (d > 0 && d < 400) {
      total += d;
      validReadings++;
    }
    delay(60);
  }
  
  if (validReadings > 0) {
    data.distanceCm  = total / validReadings;
    data.levelPercent = calculateLevel(data.distanceCm);
    data.sensorOk    = true;
  } else {
    data.distanceCm   = -1;
    data.levelPercent = -1;
    data.sensorOk     = false;
  }
  
  // Send via NRF24
  bool sent = radio.write(&data, sizeof(data));
  
  Serial.print("Level: " + String(data.levelPercent) + "%");
  Serial.print(" | Distance: " + String(data.distanceCm) + " cm");
  Serial.println(sent ? " | Sent OK" : " | Send FAILED");
  
  delay(2000); // send every 2 seconds
}
