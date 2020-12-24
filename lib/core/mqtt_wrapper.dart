import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';



class MqttWrapper {

  MqttServerClient client;

  final VoidCallback onConnectedCallback;
  final VoidCallback onDisconnectedCallback;
  final VoidCallback onAutoReconnectCallback;

  final Function(String) onPayloadReceivedCallback;


  MqttWrapper(this.onConnectedCallback, this.onDisconnectedCallback, this.onPayloadReceivedCallback, this.onAutoReconnectCallback);

  void prepareMqttClient(String userSubscribeTopicName,String userPublishTopicName, String brokerUri, int brokerPort, String token, String appId) async {
    _setupMqttClient(brokerUri, brokerPort, appId);
    await _connectClient(token);
  }

  void publishMessage(String message, String topicName) {
    _publishMessage(message, topicName);
  }

  Future<void> _connectClient(String token) async {
    try {
      print('MQTTWrapper::EMQX client connecting....');
      await client.connect(token,token);
    } on Exception catch (e) {
      print('MQTTWrapper::client exception - $e');
    }
  }

  void _setupMqttClient(String brokerUri, int brokerPort, String appId) {
    client = MqttServerClient.withPort(brokerUri, appId, brokerPort);
    client.logging(on: true);
    client.autoReconnect = true;
    client.onDisconnected = _onDisconnected;
    client.onAutoReconnect = _onAutoReconnect;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  void subscribeToTopic(String userSuscribeTopicName) {
    print('MQTTClientWrapper::Subscribing to the $userSuscribeTopicName topic');
    client.subscribe(userSuscribeTopicName, MqttQos.atMostOnce);

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String newPayloadJson =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      onPayloadReceivedCallback(newPayloadJson);
    });
  }


  void _publishMessage(String message, String topicName) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    print('MQTTClientWrapper::Publishing message $message to topic ${topicName}');
    client.publishMessage(topicName, MqttQos.exactlyOnce, builder.payload);
  }

  void _onSubscribed(String topic) {
    print('MQTTWrapper::Subscription confirmed for topic $topic');
  }

  void _onDisconnected() {
    print('MQTTWrapper::OnDisconnected client callback - Client disconnection');
    onDisconnectedCallback();
  }

  void _onConnected() {
    print('MQTTWrapper::OnConnected client callback - Client connection was sucessful');
    onConnectedCallback();
  }

  void _onAutoReconnect() {
    print('MQTTWrapper::onAutoReconnect client callback - Client disconnection');
    onAutoReconnectCallback();
  }

}