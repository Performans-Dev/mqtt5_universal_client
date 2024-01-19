// ignore_for_file: avoid_print

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mqtt5_universal_client/models/message.dart';
import 'package:mqtt5_universal_client/models/topic.dart';
import 'package:mqtt5_universal_client/mqtt5_universal_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Universal MQTT5 Client",
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TopicDefinition> topics = [
    TopicDefinition(topic: 'your/topic/here'),
    TopicDefinition(topic: 'your/another/topic/here'),
  ];
  List<MessageDefinition> receivedMessages = [];
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    runInitTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                receivedMessages.clear();
              });
            },
          )
        ],
      ),
      body: isOnline
          ? Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text("Send datetime as message to "),
                    ElevatedButton(
                      onPressed: () => sendMessage(0),
                      child: Text(topics[0].topic),
                    ),
                    ElevatedButton(
                      onPressed: () => sendMessage(1),
                      child: Text(topics[1].topic),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) => ListTile(
                      title: Text(receivedMessages[index].message),
                      subtitle: Text(receivedMessages[index].topic),
                      trailing:
                          Text(receivedMessages[index].time.toIso8601String()),
                    ),
                    itemCount: receivedMessages.length,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> runInitTask() async {
    final String id = getRandomString(12);
    Mqtt5UniversalClient.initialize(
      serverAddress: 'your.server.address',
      username: 'your_username',
      password: 'your_password',
      clientIdentifier: id,
      isSecure: true,
      mqttPort: 8883,
      webSocketPort: 8084,
      onMessageReceived: onMessageReceived,
    );
    await Future.delayed(const Duration(seconds: 1));
    await connect();
    subscribe();
  }

  Future<void> connect() async {
    final result = await Mqtt5UniversalClient.connect();
    setState(() {
      isOnline = result;
    });
    print("Connection result: $result");
  }

  void subscribe() {
    Mqtt5UniversalClient.subscribe(topics);
  }

  void sendMessage(int topicIndex) {
    final String message =
        "This is a sample message ${DateTime.now().toIso8601String()}";
    Mqtt5UniversalClient.broadcast(topics[topicIndex], message);
  }

  void onMessageReceived(MessageDefinition message) {
    print("*** messageReceived");
    print("Topic: ${message.topic}");
    print("Message: ${message.message}");
    print("Time: ${message.time}");
    setState(() {
      receivedMessages.add(message);
    });
  }

  String getRandomString(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    final rnd = math.Random();

    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }
}
