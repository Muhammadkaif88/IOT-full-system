import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  static const String _broker   = '953f09ca32294f208d3850080482d3c2.s1.eu.hivemq.cloud';
  static const int    _port     = 8883;
  static const String _username = 'prozmic';
  static const String _password = '2004@2004';

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

      final clientId = 'sn${DateTime.now().millisecondsSinceEpoch % 99999}';
      _client = MqttServerClient.withPort(_broker, clientId, _port);

      // Use MQTT v5 protocol — HiveMQ cloud needs this
      _client!.protocol = MqttClientProtocol.v5;

      _client!.secure = true;
      _client!.keepAlivePeriod = 20;
      _client!.connectTimeoutPeriod = 15000;
      _client!.autoReconnect = false;
      _client!.logging(on: false);

      _client!.onConnected    = () => print('MQTT Connected!');
      _client!.onDisconnected = () => print('MQTT Disconnected');

      final connMsg = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(_username, _password)
          .startClean();
      _client!.connectionMessage = connMsg;

      print('Connecting to HiveMQ...');
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
