import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'dart:io';

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
      // Disconnect if already connected
      if (_client != null && isConnected) return true;

      final clientId = 'smartnest_${DateTime.now().millisecondsSinceEpoch}';
      _client = MqttServerClient.withPort(_broker, clientId, _port);

      // TLS/SSL setup
      _client!.secure = true;
      _client!.securityContext = SecurityContext.defaultContext;

      _client!.keepAlivePeriod = 30;
      _client!.connectTimeoutPeriod = 10000;
      _client!.autoReconnect = true;
      _client!.logging(on: true); // enable logs to debug

      _client!.onConnected = () => print('✅ MQTT Connected!');
      _client!.onDisconnected = () => print('❌ MQTT Disconnected');
      _client!.onAutoReconnected = () => print('🔄 MQTT Reconnected');


      final connMsg = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(_username, _password)
          .withWillQos(MqttQos.atLeastOnce)
          .startClean();
      _client!.connectionMessage = connMsg;

      print('Connecting to HiveMQ...');
      final status = await _client!.connect();
      print('Connection status: ${status?.state}');

      if (!isConnected) {
        print('Connection failed: ${status?.state}');
        return false;
      }

      // Listen to messages
      _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> msgs) {
        for (final m in msgs) {
          final pub = m.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
              pub.payload.message);
          print('📩 Message on ${m.topic}: $payload');
          onMessageReceived?.call(m.topic, payload);
        }
      });

      return true;
    } catch (e) {
      print('MQTT connect error: $e');
      return false;
    }
  }

  void publish(String topic, Map<String, dynamic> data) {
    if (!isConnected) {
      print('Cannot publish — not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(data));
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('📤 Published to $topic: ${jsonEncode(data)}');
  }

  void subscribe(String topic) {
    if (!isConnected) return;
    _client!.subscribe(topic, MqttQos.atLeastOnce);
    print('📥 Subscribed to $topic');
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }
}
