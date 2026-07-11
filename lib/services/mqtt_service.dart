import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  // HiveMQ WebSocket URL (port 8884 = WSS, works on Android without TLS issues)
  static const String _wsUrl    = 'wss://953f09ca32294f208d3850080482d3c2.s1.eu.hivemq.cloud:8884/mqtt';
  static const String _username = 'prozmic';
  static const String _password = '2004@2004';

  MqttBrowserClient? _client;
  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Function(String topic, String message)? onMessageReceived;

  Future<bool> connect() async {
    try {
      if (_client != null) {
        try { _client!.disconnect(); } catch (_) {}
        _client = null;
      }

      final clientId = 'sn${DateTime.now().millisecondsSinceEpoch % 99999}';

      // WebSocket connection to HiveMQ — works on Android perfectly
      _client = MqttBrowserClient(_wsUrl, clientId);
      _client!.keepAlivePeriod = 20;
      _client!.connectTimeoutPeriod = 15000;
      _client!.autoReconnect = true;
      _client!.logging(on: false);

      _client!.onConnected    = () => print('✅ MQTT Connected via WebSocket!');
      _client!.onDisconnected = () => print('❌ MQTT Disconnected');

      final connMsg = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(_username, _password)
          .startClean();
      _client!.connectionMessage = connMsg;

      print('Connecting to HiveMQ via WSS...');
      final status = await _client!.connect();
      print('Status: ${status?.state} / ${status?.returnCode}');

      if (!isConnected) {
        print('Connection failed: ${status?.state}');
        return false;
      }

      _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> msgs) {
        for (final m in msgs) {
          final pub = m.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
              pub.payload.message);
          print('📩 ${m.topic}: $payload');
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
    if (!isConnected) {
      print('Not connected — cannot publish');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(data));
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('📤 $topic: ${jsonEncode(data)}');
  }

  void subscribe(String topic) {
    if (!isConnected) return;
    _client!.subscribe(topic, MqttQos.atLeastOnce);
    print('📥 Subscribed: $topic');
  }

  void disconnect() {
    try { _client?.disconnect(); } catch (_) {}
    _client = null;
  }
}
