import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LedService {
  static final LedService _instance = LedService._internal();
  factory LedService() => _instance;
  LedService._internal();

  String espIp = '192.168.1.100';
  bool isConnected = false;

  Future<void> loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    espIp = prefs.getString('led_esp_ip') ?? '192.168.1.100';
  }

  Future<void> saveIp(String ip) async {
    espIp = ip.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('led_esp_ip', espIp);
  }

  Future<bool> ping() async {
    try {
      final res = await http.get(
        Uri.parse('http://$espIp/ping'),
      ).timeout(const Duration(seconds: 3));
      isConnected = res.statusCode == 200;
      return isConnected;
    } catch (_) {
      isConnected = false;
      return false;
    }
  }

  Future<bool> sendCommand(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('http://$espIp/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 3));
      isConnected = res.statusCode == 200;
      return isConnected;
    } catch (e) {
      isConnected = false;
      return false;
    }
  }

  Future<bool> sendFull({
    required bool on,
    required String color,
    required String effect,
    required int brightness,
    required int speed,
  }) => sendCommand({
    'on': on,
    'color': color,
    'effect': effect,
    'brightness': brightness,
    'speed': speed,
  });
}
