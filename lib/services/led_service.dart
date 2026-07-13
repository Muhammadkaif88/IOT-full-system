import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Direct HTTP control — no MQTT needed!
// Phone → WiFi → ESP32 directly
class LedService {
  static final LedService _instance = LedService._internal();
  factory LedService() => _instance;
  LedService._internal();

  String _espIp = '192.168.1.100'; // ESP32 IP — auto saved
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    _espIp = prefs.getString('led_esp_ip') ?? '192.168.1.100';
  }

  Future<void> saveIp(String ip) async {
    _espIp = ip;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('led_esp_ip', ip);
  }

  // Check if ESP32 is reachable
  Future<bool> ping() async {
    try {
      final res = await http.get(
        Uri.parse('http://$_espIp/ping'),
      ).timeout(const Duration(seconds: 3));
      _isConnected = res.statusCode == 200;
      return _isConnected;
    } catch (_) {
      _isConnected = false;
      return false;
    }
  }

  // Send command to ESP32
  Future<bool> sendCommand(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('http://$_espIp/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (e) {
      print('LED command error: $e');
      _isConnected = false;
      return false;
    }
  }

  Future<bool> setOn(bool on) => sendCommand({'on': on});
  Future<bool> setColor(String hex) => sendCommand({'color': hex});
  Future<bool> setEffect(String effect) => sendCommand({'effect': effect});
  Future<bool> setBrightness(int brightness) => sendCommand({'brightness': brightness});
  Future<bool> setSpeed(int speed) => sendCommand({'speed': speed});

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
