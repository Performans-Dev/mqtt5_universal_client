library mqtt5_universal_client;

import 'dart:developer';

import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_universal_client/models/message.dart';
import 'package:mqtt5_universal_client/models/topic.dart';

import 'clients/server.dart' if (dart.library.html) 'clients/browser.dart'
    as mqttsetup;

class Mqtt5UniversalClient {
  /// Client constructor
  static MqttClient _client = MqttClient("", "");

  /// Username and password for mqtt connection
  static String _username = "";
  static String _password = "";

  ///
  static late void Function(MessageDefinition) _onMessageReceived;

  ///
  static bool _initialized = false;
  static bool get initialized => _initialized;

  ///
  static String _clientIdentifier = '';
  static String get clientIdentifier => _clientIdentifier;

  ///
  static MqttConnectionState _connectionState =
      MqttConnectionState.disconnected;
  static MqttConnectionState get connectionState => _connectionState;

  /// initialization of the mqtt client
  static void initialize({
    required String serverAddress,
    required String clientIdentifier,
    required int mqttPort,
    required int webSocketPort,
    required bool isSecure,
    String webSocketSuffix = '/mqtt',
    required String username,
    required String password,
    Function()? onDisconnected,
    Function()? onConnected,
    Function()? pongCallback,
    Function(String?)? onSubscribed,
    bool logging = false,
    int keepAlivePeriod = 20,
    required void Function(MessageDefinition) onMessageReceived,
  }) {
    MqttClient c = mqttsetup.setup(
      serverAddress: serverAddress,
      clientIdentifier: clientIdentifier,
      mqttPort: mqttPort,
      webSocketPort: webSocketPort,
      isSecure: isSecure,
      username: username,
      password: password,
      keepAlivePeriod: keepAlivePeriod,
      logging: logging,
      onConnected: onConnected,
      onDisconnected: onDisconnected,
      onSubscribed: onSubscribed,
      pongCallback: pongCallback,
      webSocketSuffix: webSocketSuffix,
    );

    _client = c;
    _initialized = true;
    _username = username;
    _password = password;
    _onMessageReceived = onMessageReceived;
    _clientIdentifier = clientIdentifier;
  }

  /// mqtt connection method.
  /// returns false if not initialized or on exception
  /// returns true when connected
  static Future<bool> connect() async {
    if (!initialized) {
      _connectionState =
          _client.connectionStatus?.state ?? MqttConnectionState.disconnected;
      return false;
    }

    try {
      await _client.connect(_username, _password);
      _connectionState =
          _client.connectionStatus?.state ?? MqttConnectionState.disconnected;
      return true;
    } on Exception catch (e) {
      _connectionState =
          _client.connectionStatus?.state ?? MqttConnectionState.disconnected;
      log(e.toString(), name: 'Mqtt5UniversalClient');
      return false;
    }
  }

  /// disconnects mqtt client from servers
  static void disconnect() {
    _client.disconnect();
    _connectionState =
        _client.connectionStatus?.state ?? MqttConnectionState.disconnected;
  }

  /// subscribes to the given list and registers listeners
  /// returns true when succeeds
  /// returns false if client is not connected
  static bool subscribe(List<TopicDefinition> topics) {
    if (_client.connectionStatus!.state != MqttConnectionState.connected) {
      _connectionState =
          _client.connectionStatus?.state ?? MqttConnectionState.disconnected;
      return false;
    }

    for (TopicDefinition topic in topics) {
      final subscription = _client.subscribe(topic.topic, topic.qos);
      log("Subscribed to ${subscription?.topic}", name: "Mqtt5UniversalClient");
    }

    _client.updates.listen(
      (List<MqttReceivedMessage<MqttMessage>> event) {
        final receivedPayload = event[0].payload as MqttPublishMessage;
        final receivedMessage = MqttUtilities.bytesToStringAsString(
            receivedPayload.payload.message!);
        final topic = receivedPayload.variableHeader!.topicName;
        final MessageDefinition message = MessageDefinition.populate(
          topic,
          receivedMessage,
        );
        _onMessageReceived(message);
      },
    );
    return true;
  }

  /// sends mqtt message to given topic
  /// returns message id (int)
  /// returns -1 if fails
  static int broadcast(TopicDefinition topic, String message) {
    if (_client.connectionStatus!.state != MqttConnectionState.connected) {
      _connectionState =
          _client.connectionStatus?.state ?? MqttConnectionState.disconnected;
      return -1;
    }
    final builder = MqttPayloadBuilder();
    builder.addString(message);
    final int messageId = _client.publishMessage(
      topic.topic,
      topic.qos,
      builder.payload!,
      retain: topic.retain,
    );
    log("Message Sent ($messageId)", name: "Mqtt5UniversalClient");
    return messageId;
  }
}
