import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:opentok_flutter_samples/src/config/sdk_states.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/config/open_tok_config.dart';


class OneToOneVideo extends StatelessWidget {
  const OneToOneVideo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("One to One Video"),
        ),
        body: const CallWidget(title: 'One to One Video')
    );
  }
}

class CallWidget extends StatefulWidget {
  const CallWidget({Key key = const Key("any_key"), required this.title}) : super(key: key);
  final String title;

  @override
  _CallWidgetState createState() => _CallWidgetState();
}

class _CallWidgetState extends State<CallWidget> {
  SdkState _sdkState = SdkState.loggedOut;
  bool _publishAudio = true;
  bool _publishVideo = true;

  static const platformMethodChannel = MethodChannel('com.vonage.one_to_one_video');

  _CallWidgetState() {
    platformMethodChannel.setMethodCallHandler(methodCallHandler);

    _initSession();
  }

  Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateState':
        {
          setState(() {
            var arguments = 'SdkState.${methodCall.arguments}';
            _sdkState = SdkState.values.firstWhere((v) {
              return v.toString() == arguments;
            });
          });
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _initSession() async {
    await requestPermissions();

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


  Future<void> requestPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  Future<void> _swapCamera() async {
    try {
      await platformMethodChannel.invokeMethod('swapCamera');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _toggleAudio() async {
    _publishAudio = !_publishAudio;

    dynamic params = {'publishAudio': _publishAudio};

    try {
      await platformMethodChannel.invokeMethod('toggleAudio', params);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _toggleVideo() async {
    _publishVideo = !_publishVideo;
    _updateView();

    dynamic params = {'publishVideo': _publishVideo};

    try {
      await platformMethodChannel.invokeMethod('toggleVideo', params);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[const SizedBox(), _updateView()],
        ),
      );
  }

  Widget _updateView() {

    if (_sdkState == SdkState.loggedOut) {
      return ElevatedButton(
          onPressed: () {
            _initSession();
          },
          child: const Text("Init session"));
    } else if (_sdkState == SdkState.wait) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.loggedIn) {
      return Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: const PlatFormSpecificView(key: Key("any_key")),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _swapCamera();
                },
                child: const Text("Swap " "Camera"),
              ),
              ElevatedButton(
                onPressed: () {
                  _toggleAudio();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (!_publishAudio) return Colors.grey;
                      return Colors.lightBlue;
                    },
                  ),
                ),
                child: const Text("Toggle Audio"),
              ),
              ElevatedButton(
                onPressed: () {
                  _toggleVideo();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (!_publishVideo) return Colors.grey;
                      return Colors.lightBlue;
                    },
                  ),
                ),
                child: const Text("Toggle Video"),
              ),
            ],
          ),
        ],
      );
    } else {
      return const Center(child: Text("ERROR"));
    }
  }
}

class PlatFormSpecificView extends StatelessWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();
  const PlatFormSpecificView({
    required Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = {"someInit": "initData"};
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
          viewType: 'opentok-video-container',
          creationParams: args,
          creationParamsCodec: _decoder);
    }
    return UiKitView(
        viewType: 'opentok-video-container',
        creationParams: args,
        creationParamsCodec: _decoder);
  }
}

