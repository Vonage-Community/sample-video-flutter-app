import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/config/open_tok_config.dart';

class Signaling extends StatelessWidget {
  const Signaling({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Signalling"),
        ),
        body: const SignalWidget(title: 'Signalling'));
  }
}

class SignalWidget extends StatefulWidget {
  const SignalWidget({Key key = const Key("any_key"), required this.title})
      : super(key: key);
  final String title;

  @override
  _SignalWidgetState createState() => _SignalWidgetState();
}

class _SignalWidgetState extends State<SignalWidget> {
  static const platformMethodChannel = MethodChannel('com.vonage.signalling');
  TextEditingController nameController = TextEditingController();

  final List<String> messages = <String>[];
  final List<bool> isRemote = <bool>[];

  _SignalWidgetState() {
    platformMethodChannel.setMethodCallHandler(methodCallHandler);

    _initSession();
  }

  Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateMessages':
        setState(() {
          messages.insert(0, methodCall.arguments["message"]);
          isRemote.insert(0, methodCall.arguments["remote"]);
        });
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _initSession() async {
    dynamic params = {
      'apiKey': OpenTokConfig.apiKey,
      'sessionId': OpenTokConfig.sessionID,
      'token': OpenTokConfig.token
    };

    try {
      await platformMethodChannel.invokeMethod('initSession', params);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _sendMessage() async {
    dynamic params = {'message': nameController.text};
    try {
      await platformMethodChannel.invokeMethod('sendMessage', params);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(20),
        child: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Message',
          ),
        ),
      ),
      ElevatedButton(
        child: const Text('Send Message'),
        onPressed: () {
          _sendMessage();
        },
      ),
      Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(2),
                  color: isRemote[index] ? Colors.blue[400] : Colors.grey,
                  child: Text(
                    messages[index],
                    style: const TextStyle(fontSize: 18),
                    textAlign:
                        isRemote[index] ? TextAlign.right : TextAlign.right,
                  ),
                );
              }))
    ]);
  }
}
