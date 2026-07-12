import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  // LOCAL Mosquitto broker running on PC
  // PC ip address — same WiFi network
  static const String _broker   = '192.168.1.12'; // <-- PC IP address
  static const int    _port     = 1883;            // no TLS — simple local

  MqttServerClient? _client;
  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Function(String topic, String message)? onMessageReceived;

  Future<bool> connect() async {
    try {
      if (_client != null) {
        try { _client!.disconnect(); } catch (_) {}
        _client = null;
      }

      final clientId = 'sn_${DateTime.now().millisecondsSinceEpoch % 9999}';
      _client = MqttServerClient.withPort(_broker, clientId, _port);

      // Simple TCP — no TLS, no password — local network
      _client!.secure = false;
      _client!.keepAlivePeriod = 30;
      _client!.connectTimeoutPeriod = 8000;
      _client!.autoReconnect = true;
      _client!.logging(on: false);

      _client!.onConnected    = () => print('MQTT Local Connected!');
      _client!.onDisconnected = () => print('MQTT Disconnected');

      final connMsg = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean();
      _client!.connectionMessage = connMsg;

      print('Connecting to local broker $_broker:$_port ...');
      final status = await _client!.connect();
      print('Status: ${status?.state}');

      if (!isConnected) return false;

      _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> msgs) {
        for (final m in msgs) {
          final pub = m.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
              pub.payload.message);
          onMessageReceived?.call(m.topic, payload);
        }
      });

      return true;
    } catch (e) {
      print('MQTT error: $e');
      return false;
    }
  }

  void publish(String topic, Map<String, dynamic> data) {
    if (!isConnected) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(data));
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('Published: $topic => ${jsonEncode(data)}');
  }

  void subscribe(String topic) {
    if (!isConnected) return;
    _client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  void disconnect() {
    try { _client?.disconnect(); } catch (_) {}
    _client = null;
  }
}
