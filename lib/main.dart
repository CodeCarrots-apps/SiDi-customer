import 'package:flutter/material.dart';
// import 'package:sidi/presentation/homescreen.dart';
import 'package:sidi/presentation/loginscreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SIDI App",
      home: LoginScreen(),
    );
  }
}
