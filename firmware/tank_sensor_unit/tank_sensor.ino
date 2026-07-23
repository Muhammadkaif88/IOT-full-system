// ================================================================
// SmartNest Water Tank — SENSOR UNIT (Tank side)
// ESP32 + HC-SR04 + NRF24L01 PA+LNA
// Measures water level, sends to kitchen unit via NRF24
// ================================================================

#include <SPI.h>
#include <RF24.h>

// ===== NRF24 pins (ESP32) =====
// CE  → GPIO 4
// CSN → GPIO 5
// SCK → GPIO 18
// MOSI→ GPIO 23
// MISO→ GPIO 19
RF24 radio(4, 5);
const byte address[6] = "TANK1";

// ===== HC-SR04 pins =====
#define TRIG_PIN  26
#define ECHO_PIN  27

// ===== Tank config =====
#define TANK_HEIGHT_CM  150  // Change to your tank height in cm
#define TANK_EMPTY_CM   140  // Distance when tank is empty (sensor to bottom)
#define TANK_FULL_CM    10   // Distance when tank is full (sensor to water)

// Data packet to send
struct TankData {
  uint8_t  level;      // 0-100%
  float    distanceCm; // raw distance
  bool     sensorOk;   // sensor working?
  uint32_t timestamp;  // millis
};

TankData tankData;
unsigned long lastSend = 0;
const int SEND_INTERVAL = 2000; // send every 2 seconds

void setup() {
  Serial.begin(115200);
  Serial.println("SmartNest Tank Sensor Unit starting...");

  // HC-SR04
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // NRF24
  if (!radio.begin()) {
    Serial.println("NRF24 init failed! Check wiring.");
    while (1) { delay(1000); }
  }

  radio.setPALevel(RF24_PA_MAX);      // Max power for PA+LNA module
  radio.setDataRate(RF24_250KBPS);    // 250kbps for better range
  radio.setChannel(108);              // Channel 108 (above WiFi)
  radio.openWritingPipe(address);
  radio.stopListening();              // Transmitter mode

  Serial.println("NRF24 ready! Transmitting...");
  Serial.printf("Tank height: %d cm\n", TANK_HEIGHT_CM);
}

float measureDistance() {
  // Send ultrasonic pulse
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Measure echo
  long duration = pulseIn(ECHO_PIN, HIGH, 30000); // 30ms timeout
  if (duration == 0) return -1; // no echo = error

  float distance = (duration * 0.034) / 2.0;
  return distance;
}

int calculateLevel(float distanceCm) {
  if (distanceCm < 0) return -1; // error
  // Map distance to level%
  // When distance = TANK_FULL_CM → 100%
  // When distance = TANK_EMPTY_CM → 0%
  int level = map(
    (int)(distanceCm * 10),
    TANK_EMPTY_CM * 10,
    TANK_FULL_CM * 10,
    0, 100
  );
  return constrain(level, 0, 100);
}

void loop() {
  if (millis() - lastSend >= SEND_INTERVAL) {
    // Take 3 readings and average
    float total = 0;
    int valid = 0;
    for (int i = 0; i < 3; i++) {
      float d = measureDistance();
      if (d > 0 && d < 400) {
        total += d;
        valid++;
      }
      delay(60);
    }

    if (valid > 0) {
      tankData.distanceCm = total / valid;
      tankData.level      = calculateLevel(tankData.distanceCm);
      tankData.sensorOk   = true;
    } else {
      tankData.distanceCm = -1;
      tankData.level      = 0;
      tankData.sensorOk   = false;
    }
    tankData.timestamp = millis();

    // Send via NRF24
    bool sent = radio.write(&tankData, sizeof(tankData));

    Serial.printf("Distance: %.1f cm | Level: %d%% | Sent: %s\n",
      tankData.distanceCm,
      tankData.level,
      sent ? "OK" : "FAIL"
    );

    lastSend = millis();
  }
}
