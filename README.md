# SmartNest — IoT Home Automation App

A Flutter app to control IoT home automation products: smart lights, fans, curtains, water tank monitoring, and WS2812 LED tubes/bulbs with 22 effects + music reactive mode.

## Features
- Dashboard with live device cards
- Rooms view (Living room, Bedroom, Kitchen, Bathroom, Utility)
- LED Studio — colour picker, 22 effects, music reactive mode
- Scenes (Morning, Night, Movie, Away)
- Schedule / automations
- Notifications / alerts
- Settings (WiFi, MQTT broker config)

## Tech stack
- Flutter (Dart)
- MQTT (mqtt_client package) for ESP32/ESP8266 device communication
- Dark premium UI theme (#6C63FF accent)

## Hardware
- ESP32 / ESP8266 boards
- WS2812B LED strips for LED tube products
- HC-SR04 ultrasonic sensor for water tank
- Relay modules, stepper motors for curtains

## Getting started
```bash
flutter pub get
flutter run -d windows   # or -d chrome, or connect an Android device
```

## Project structure
```
lib/
  main.dart
  screens/        - all app screens
  widgets/        - reusable widgets (device card, bottom nav)
  models/         - device data model + in-memory store
```

## Status
- [x] UI complete for all screens (no backend yet)
- [ ] Firebase backend (auth + realtime device state) — to be added
- [ ] MQTT live connection to ESP32 devices — to be added
- [ ] ESP32 firmware for each product
