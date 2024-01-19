import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

import 'package:mqtt5_universal_client/mqtt5_universal_client.dart';

void main() {
  test('checks setup', () async {
    expect(Mqtt5UniversalClient.initialized, false);
    expect(Mqtt5UniversalClient.clientIdentifier, '');
    const identifier = "ABC123";
    Mqtt5UniversalClient.initialize(
      serverAddress: 'not.a-valid.domain',
      clientIdentifier: identifier,
      mqttPort: 0,
      webSocketPort: 0,
      isSecure: true,
      username: '',
      password: '',
      onMessageReceived: (p0) {},
    );
    expect(Mqtt5UniversalClient.initialized, true);
    expect(Mqtt5UniversalClient.clientIdentifier, identifier);
    bool connectionResult = await Mqtt5UniversalClient.connect();
    expect(connectionResult, false);
    Mqtt5UniversalClient.disconnect();
    expect(
        Mqtt5UniversalClient.connectionState, MqttConnectionState.disconnected);
  });
}
