import 'package:flutter/material.dart';
import 'package:room_things_detector/views/camera_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Things Detector",
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const CameraView(),
    );
  }
}
