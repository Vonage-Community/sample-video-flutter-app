import 'package:flutter/material.dart';
import 'package:opentok_flutter_samples/screen_sharing.dart';
import 'package:opentok_flutter_samples/signaling.dart';
import 'archiving.dart';
import 'multi_video.dart';
import 'one_to_one_video.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Video SDK Samples"),
        ),
        body:
        Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[const SizedBox(), _updateView(context)],
            )
    ));
  }
}

Widget _updateView(BuildContext context) {
    return
      Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OneToOneVideo())
                    );
                  }, child: const Text("One to One Video Call")),

            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MultiVideo())
                    );
                  }, child: const Text("Multi Party Video Call")),

                ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Signaling())
                    );
                  }, child: const Text("Signalling")),

                ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Archiving())
                    );
                  }, child: const Text("Archiving")),

                ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScreenSharing())
                    );
                  }, child: const Text("View Sharing")),

                ]),
          ]
      );
}
