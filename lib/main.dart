import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidi/presentation/splashscreen.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:sidi/services/appointments_sync_service.dart';
import 'package:sidi/services/credential_service.dart';
import 'package:sidi/controller/wallet_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    debugPrint('[main] BackgroundFetch headless task registered');
  } catch (e) {
    debugPrint('[main] BackgroundFetch headless registration error: $e');
  }

  await AppointmentsSyncService.initialize();
  await CredentialService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<WalletController>(() => WalletController());
      }),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
