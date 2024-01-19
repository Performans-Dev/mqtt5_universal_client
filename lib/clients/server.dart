import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

MqttServerClient setup({
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
}) {
  final client =
      MqttServerClient.withPort(serverAddress, clientIdentifier, mqttPort);
  client.logging(on: logging);
  client.port = mqttPort;
  client.keepAlivePeriod = keepAlivePeriod;
  client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;
  client.onSubscribed = (MqttSubscription s) => onSubscribed!(s.topic.rawTopic);
  client.pongCallback = pongCallback;
  client.autoReconnect = true;
  client.resubscribeOnAutoReconnect = true;
  client.secure = true;
  client.onBadCertificate = (a) => true;
  client.clientIdentifier = clientIdentifier;
  return client;
}
