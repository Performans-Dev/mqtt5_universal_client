import 'package:mqtt5_client/mqtt5_client.dart';

class TopicDefinition {
  String topic;
  MqttQos qos;
  bool retain;
  TopicDefinition({
    required this.topic,
    this.qos = MqttQos.atLeastOnce,
    this.retain = false,
  });
}
