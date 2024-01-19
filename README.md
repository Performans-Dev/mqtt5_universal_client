<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Mqtt5UniversalClient is a simplified version of Mqtt5 client for basic usage.

## How to use

With Flutter:

```
 $ flutter pub add mqtt5_universal_client
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```
dependencies:
    mqtt5_universal_client: ^1.0.0
```

Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

Import it
Now in your Dart code, you can use:

```dart
import 'package:mqtt5_universal_client/mqtt5_universal_client.dart';
```


Initialize before using in anywhere (before runApp is recommended)

```dart
Mqtt5UniversalClient.initialize(
      serverAddress: 'your.server.address',
      username: 'your_username',
      password: 'your_password',
      clientIdentifier: id,
      isSecure: true,
      mqttPort: 8883,
      webSocketPort: 8084,
      onMessageReceived: (receivedMessage){
        print("${receivedMessage.topic} - ${receviedMessage.message}")
      },
    );
```

After initialization, you may call connect() anytime you want.

```dart
await Mqtt5UniversalClient.connect();
```

When connected you may call subscribe()

```dart
Mqtt5UniversalClient.subscribe(topicList);
```

And to send message simply call
```dart
 Mqtt5UniversalClient.broadcast(topic, message);
```


![score](https://img.shields.io/pub/points/mqtt5_universal_client)