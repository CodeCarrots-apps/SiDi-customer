import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidi/presentation/splashscreen.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:sidi/services/appointments_sync_service.dart';
// import 'package:sidi/presentation/mainscreen.dart';
// import 'package:sidi/view/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    debugPrint('[main] BackgroundFetch headless task registered');
  } catch (e) {
    debugPrint('[main] BackgroundFetch headless registration error: $e');
  }

  await AppointmentsSyncService.initialize();
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
