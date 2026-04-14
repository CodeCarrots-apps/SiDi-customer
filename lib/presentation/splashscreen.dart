import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sidi/presentation/loginscreen.dart';
import 'package:sidi/presentation/mainscreen.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sidi/utils/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Color _backgroundColor = Color(0xFFFDFCF8);
  static const Color _haloColor = Color(0xFFFAF5E9);
  static const Color _brandGold = Color(0xFFD9AE60);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 3), _navigateFromSplash);
  }

  Future<bool> _isTokenValid(String token) async {
    try {
      final response =
          await Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              validateStatus: (_) => true,
            ),
          ).get(
            AppConstants.profile,
            options: Options(
              headers: <String, dynamic>{
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ),
          );

      if (response.statusCode == 200) {
        return true;
      }

      debugPrint(
        '[SplashScreen] Token validation failed: status=${response.statusCode}',
      );
      return false;
    } catch (error) {
      debugPrint('[SplashScreen] Token validation error: $error');
      return false;
    }
  }

  Future<void> _navigateFromSplash() async {
    if (!mounted) {
      return;
    }

    final token = await TokenStorage.getToken();
    debugPrint(
      '[SplashScreen] Stored auth token: ${token == null ? '<null>' : token}',
    );
    final isValid = token != null && token.isNotEmpty
        ? await _isTokenValid(token)
        : false;

    if (!isValid) {
      await TokenStorage.deleteToken();
    }

    final destination = isValid ? const MainScreen() : const LoginScreen();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => destination,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashScreen._backgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: _SplashBackdrop()),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: const _BrandMark(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 1.48;

    return Stack(
      children: [
        Positioned(
          left: (size.width - circleSize) / 2,
          top: size.height * 0.18,
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: const BoxDecoration(
              color: SplashScreen._haloColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [const _LogoGlyph(), const SizedBox(height: 6)],
    );
  }
}

class _LogoGlyph extends StatelessWidget {
  const _LogoGlyph();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: SplashScreen._brandGold.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        width: 200,

        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
    );
  }
}
