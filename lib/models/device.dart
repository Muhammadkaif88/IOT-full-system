import 'package:flutter/material.dart';

class Device {
  String id;
  String name;
  String type; // light, fan, curtain, water, led
  String room;
  IconData icon;
  Color color;
  bool isOn;
  String sub;
  String mqttTopic;
  int? brightness;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    required this.icon,
    required this.color,
    this.isOn = false,
    this.sub = 'Off',
    required this.mqttTopic,
    this.brightness,
  });
}

// Shared device list - in-memory store for the whole app
class DeviceStore {
  static final DeviceStore _instance = DeviceStore._internal();
  factory DeviceStore() => _instance;
  DeviceStore._internal();

  final List<Device> devices = [
    Device(
      id: 'light1',
      name: 'Living light',
      type: 'light',
      room: 'Living room',
      icon: Icons.lightbulb_outline,
      color: const Color(0xFF6C63FF),
      isOn: true,
      sub: '80%',
      mqttTopic: 'home/living/light1',
      brightness: 80,
    ),
    Device(
      id: 'fan1',
      name: 'Ceiling fan',
      type: 'fan',
      room: 'Living room',
      icon: Icons.air,
      color: const Color(0xFF1D9E75),
      isOn: true,
      sub: 'Speed 3',
      mqttTopic: 'home/living/fan1',
    ),
    Device(
      id: 'curtain1',
      name: 'Smart curtain',
      type: 'curtain',
      room: 'Living room',
      icon: Icons.view_agenda_outlined,
      color: const Color(0xFF378ADD),
      isOn: true,
      sub: 'Open',
      mqttTopic: 'home/living/curtain1',
    ),
    Device(
      id: 'light2',
      name: 'Bedroom light',
      type: 'light',
      room: 'Bedroom',
      icon: Icons.lightbulb_outline,
      color: const Color(0xFFEF9F27),
      isOn: false,
      sub: 'Off',
      mqttTopic: 'home/bedroom/light1',
      brightness: 60,
    ),
    Device(
      id: 'led1',
      name: 'LED Tube',
      type: 'led',
      room: 'Living room',
      icon: Icons.light_mode_outlined,
      color: const Color(0xFFA78BFA),
      isOn: true,
      sub: 'Rainbow',
      mqttTopic: 'home/living/led1',
    ),
    Device(
      id: 'water1',
      name: 'Water tank',
      type: 'water',
      room: 'Utility',
      icon: Icons.water_drop_outlined,
      color: const Color(0xFF378ADD),
      isOn: true,
      sub: '73%',
      mqttTopic: 'home/utility/water1',
    ),
    Device(
      id: 'light3',
      name: 'Kitchen light',
      type: 'light',
      room: 'Kitchen',
      icon: Icons.lightbulb_outline,
      color: const Color(0xFFEF9F27),
      isOn: false,
      sub: 'Off',
      mqttTopic: 'home/kitchen/light1',
      brightness: 70,
    ),
    Device(
      id: 'light4',
      name: 'Bathroom light',
      type: 'light',
      room: 'Bathroom',
      icon: Icons.lightbulb_outline,
      color: const Color(0xFF6C63FF),
      isOn: true,
      sub: '50%',
      mqttTopic: 'home/bathroom/light1',
      brightness: 50,
    ),
  ];

  List<String> get rooms =>
      devices.map((d) => d.room).toSet().toList();

  List<Device> devicesInRoom(String room) =>
      devices.where((d) => d.room == room).toList();

  int get onlineCount => devices.where((d) => d.isOn).length;
}
