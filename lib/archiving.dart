import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:opentok_flutter_samples/src/config/sdk_states.dart';
import 'package:permission_handler/permission_handler.dart';

class Archiving extends StatelessWidget {
  const Archiving({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Archiving"),
        ),
        body: const ArchivingWidget(title: 'Archiving')
    );
  }
}

class ArchivingWidget extends StatefulWidget {
  const ArchivingWidget({Key key = const Key("any_key"), required this.title}) : super(key: key);
  final String title;

  @override
  _ArchivingWidgetState createState() => _ArchivingWidgetState();
}

class _ArchivingWidgetState extends State<ArchivingWidget> {
  SdkState _sdkState = SdkState.loggedOut;
  bool _isArchiving = false;

  static const platformMethodChannel = MethodChannel('com.vonage.archiving');

  _ArchivingWidgetState() {
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
      case 'updateArchiving':
        {
          setState(() {
            _isArchiving = methodCall.arguments;
          });
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _initSession() async {
    await requestPermissions();
    try {
      await platformMethodChannel.invokeMethod('initSession');

    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }


  Future<void> requestPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  Future<void> _startArchive() async {
    try {
      await platformMethodChannel.invokeMethod('startArchive');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stopArchive() async {
    try {
      await platformMethodChannel.invokeMethod('stopArchive');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _playArchive() async {
    try {
      await platformMethodChannel.invokeMethod('playArchive');
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
            child: const ArchivingPlatFormSpecificView(key: Key("any_key")),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {  },
                child: Icon(
                  Icons.circle,
                  color: _isArchiving ? Colors.red : Colors.grey,
                  size: 24.0,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _startArchive();
                },
                child: const Text("Start Archiving"),
              ),
              ElevatedButton(
                onPressed: () {
                  _stopArchive();
                },
                child: const Text("Stop Archiving"),
              ),
              ElevatedButton(
                onPressed: () {
                  _playArchive();
                },
                child: const Text("Play Archive"),
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

class ArchivingPlatFormSpecificView extends StatelessWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();
  const ArchivingPlatFormSpecificView({
    required Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = {"someInit": "initData"};
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
          viewType: 'opentok-archiving-container',
          creationParams: args,
          creationParamsCodec: _decoder);
    }
    return UiKitView(
        viewType: 'opentok-archiving-container',
        creationParams: args,
        creationParamsCodec: _decoder);
  }
}

