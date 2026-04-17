import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidi/presentation/splashscreen.dart';
// import 'package:sidi/presentation/mainscreen.dart';
// import 'package:sidi/view/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
