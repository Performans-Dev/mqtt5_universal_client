class MessageDefinition {
  String topic;
  String message;
  DateTime time;
  MessageDefinition({
    required this.topic,
    required this.message,
    required this.time,
  });

  factory MessageDefinition.populate(String topic, String message) =>
      MessageDefinition(
        topic: topic,
        message: message,
        time: DateTime.now(),
      );
}
