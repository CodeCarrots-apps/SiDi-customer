import 'package:flutter/material.dart';
import 'package:sidi/presentation/splashscreen.dart';
// import 'package:sidi/presentation/mainscreen.dart';
// import 'package:sidi/view/splashscreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
