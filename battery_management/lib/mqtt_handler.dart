import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttHandler with ChangeNotifier {
  late MqttServerClient _client;
  Map<String, dynamic> _batteryData = {
    'voltage': 0.0,
    'current': 0.0,
    'temperature': 0.0,
    'soc': 0.0,
  };
  bool _isConnected = false;
  String _status = "Disconnected";

  Map<String, dynamic> get batteryData => _batteryData;
  bool get isConnected => _isConnected;
  String get status => _status;

  Future<void> connect() async {
    const broker = 'test.mosquitto.org'; // Replace with your broker
    const port = 1883;
    final clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';

    _client = MqttServerClient(broker, clientId);
    _client.port = port;
    _client.keepAlivePeriod = 30;
    _client.onDisconnected = _onDisconnected;
    _client.logging(on: false);

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .keepAliveFor(30);

    _client.connectionMessage = connMess;

    try {
      _status = "Connecting...";
      notifyListeners();

      await _client.connect();

      _isConnected = true;
      _status = "Connected";
      notifyListeners();

      _client.subscribe('battery/#', MqttQos.atLeastOnce);

      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final topic = c[0].topic;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        _processMessage(topic, payload);
      });
    } catch (e) {
      _status = "Failed: $e";
      _isConnected = false;
      notifyListeners();
    }
  }

  void _onDisconnected() {
    _isConnected = false;
    _status = "Disconnected";
    notifyListeners();
  }

  void disconnect() {
    _client.disconnect();
    _onDisconnected();
  }

  void _processMessage(String topic, String payload) {
    try {
      if (topic.endsWith('voltage')) {
        _batteryData['voltage'] = double.tryParse(payload) ?? 0.0;
      } else if (topic.endsWith('current')) {
        _batteryData['current'] = double.tryParse(payload) ?? 0.0;
      } else if (topic.endsWith('temperature')) {
        _batteryData['temperature'] = double.tryParse(payload) ?? 0.0;
      } else if (topic.endsWith('soc')) {
        _batteryData['soc'] = double.tryParse(payload) ?? 0.0;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error parsing MQTT data: $e");
    }
  }
}
