import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sidi/presentation/loginscreen.dart';

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
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) => const LoginScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
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
                return Opacity(
                  opacity: value.clamp(0, 1),
                  child: Transform.scale(scale: value, child: child),
                );
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
