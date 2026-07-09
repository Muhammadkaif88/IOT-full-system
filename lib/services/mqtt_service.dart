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
  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;
  Function(String topic, String message)? onMessageReceived;

  Future<bool> connect() async {
    _client = MqttServerClient.withPort(
        _broker, 'smartnest_app_${DateTime.now().millisecondsSinceEpoch}', _port);
    _client!.secure = true;
    _client!.keepAlivePeriod = 60;
    _client!.autoReconnect = true;
    _client!.logging(on: false);

    final connMsg = MqttConnectMessage()
        .withClientIdentifier('smartnest_${DateTime.now().millisecondsSinceEpoch}')
        .authenticateAs(_username, _password)
        .startClean();
    _client!.connectionMessage = connMsg;

    try {
      await _client!.connect();
    } catch (e) {
      print('MQTT error: $e');
      return false;
    }

    if (!isConnected) return false;

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> msgs) {
      for (final m in msgs) {
        final pub = m.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(pub.payload.message);
        onMessageReceived?.call(m.topic, payload);
      }
    });

    return true;
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

  void disconnect() => _client?.disconnect();
}
