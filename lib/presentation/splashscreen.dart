// import 'dart:async';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:sidi/presentation/loginscreen.dart';
// import 'package:sidi/presentation/mainscreen.dart';
// import 'package:sidi/utils/app_constants.dart';
// import 'package:sidi/utils/token_storage.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   static const Color _backgroundColor = Color(0xFFFDFCF8);
//   static const Color _haloColor = Color(0xFFFAF5E9);
//   static const Color _brandGold = Color(0xFFD9AE60);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   Timer? _navigationTimer;

//   @override
//   void initState() {
//     super.initState();
//     _navigationTimer = Timer(const Duration(seconds: 3), _navigateFromSplash);
//   }

//   Future<bool> _isTokenValid(String token) async {
//     try {
//       final response =
//           await Dio(
//             BaseOptions(
//               connectTimeout: const Duration(seconds: 15),
//               receiveTimeout: const Duration(seconds: 20),
//               sendTimeout: const Duration(seconds: 20),
//               validateStatus: (_) => true,
//             ),
//           ).get(
//             AppConstants.profile,
//             options: Options(
//               headers: <String, dynamic>{
//                 'Content-Type': 'application/json',
//                 'Authorization': 'Bearer $token',
//               },
//             ),
//           );

//       if (response.statusCode == 200) {
//         return true;
//       }

//       debugPrint(
//         '[SplashScreen] Token validation failed: status=${response.statusCode}',
//       );
//       return false;
//     } catch (error) {
//       debugPrint('[SplashScreen] Token validation error: $error');
//       return false;
//     }
//   }

//   Future<void> _navigateFromSplash() async {
//     if (!mounted) {
//       return;
//     }

//     final token = await TokenStorage.getToken();
//     debugPrint(
//       '[SplashScreen] Stored auth token: ${token == null ? '<null>' : token}',
//     );
//     final isValid = token != null && token.isNotEmpty
//         ? await _isTokenValid(token)
//         : false;

//     if (!isValid) {
//       await TokenStorage.deleteToken();
//     }

//     final destination = isValid ? const MainScreen() : const LoginScreen();

//     if (!mounted) {
//       return;
//     }

//     Navigator.of(context).pushReplacement(
//       PageRouteBuilder<void>(
//         pageBuilder: (_, _, _) => destination,
//         transitionsBuilder: (_, animation, _, child) {
//           return FadeTransition(opacity: animation, child: child);
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _navigationTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: SplashScreen._backgroundColor,
//       body: Stack(
//         children: [
//           const Positioned.fill(child: _SplashBackdrop()),
//           Center(
//             child: TweenAnimationBuilder<double>(
//               tween: Tween(begin: 0.92, end: 1),
//               duration: const Duration(milliseconds: 900),
//               curve: Curves.easeOutCubic,
//               builder: (context, value, child) {
//                 return Transform.scale(scale: value, child: child);
//               },
//               child: const _BrandMark(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SplashBackdrop extends StatelessWidget {
//   const _SplashBackdrop();

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final circleSize = size.width * 1.48;

//     return Stack(
//       children: [
//         Positioned(
//           left: (size.width - circleSize) / 2,
//           top: size.height * 0.18,
//           child: Container(
//             width: circleSize,
//             height: circleSize,
//             decoration: const BoxDecoration(
//               color: SplashScreen._haloColor,
//               shape: BoxShape.circle,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _BrandMark extends StatelessWidget {
//   const _BrandMark();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [const _LogoGlyph(), const SizedBox(height: 6)],
//     );
//   }
// }

// class _LogoGlyph extends StatelessWidget {
//   const _LogoGlyph();

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: SplashScreen._brandGold.withValues(alpha: 0.16),
//             blurRadius: 22,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: SizedBox(
//         height: 200,
//         width: 200,

//         child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sidi/presentation/loginscreen.dart';
import 'package:sidi/presentation/mainscreen.dart';
import 'package:sidi/presentation/widgets/update_dialog.dart';
import 'package:sidi/services/app_update_service.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sidi/utils/token_storage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme tokens
// ─────────────────────────────────────────────────────────────────────────────

abstract final class _Colors {
  static const background = Color(0xFFFDFCF8);
  static const gold = Color(0xFFD9AE60);
  static const goldLight = Color(0xFFF0D498);
  static const goldDark = Color(0xFFB8903A);
  static const orbBase = Color(0xFFFAF5E9);
}

// ─────────────────────────────────────────────────────────────────────────────
// SplashScreen
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navigationTimer;

  // Logo entrance
  late final AnimationController _logoCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final Animation<double> _logoScale = Tween<double>(
    begin: 0.60,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
  late final Animation<Offset> _logoSlide = Tween<Offset>(
    begin: const Offset(0, 0.14),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));

  // Text entrance (staggered after logo)
  late final AnimationController _textCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.5),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

  // Background orb drift
  late final AnimationController _orbCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  // Ambient glow pulse
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);
  late final Animation<double> _glowOpacity = Tween<double>(
    begin: 0.28,
    end: 0.72,
  ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

  // Loading dots
  late final AnimationController _dotsCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  // Loading indicator entrance (staggered after text)
  late final AnimationController _loadingCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<Offset> _loadingSlide = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _loadingCtrl, curve: Curves.easeOutCubic));
  late final Animation<double> _loadingOpacity = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _loadingCtrl, curve: Curves.easeOutCubic));

  // Arc ring rotation (loading indicator feel)
  late final AnimationController _arcRotateCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  late final Animation<double> _arcRotation = Tween<double>(
    begin: 0.0,
    end: 2 * math.pi,
  ).animate(_arcRotateCtrl);

  @override
  void initState() {
    super.initState();
    // Stagger: logo first, then text, then loading indicator
    _logoCtrl.forward().then((_) {
      if (mounted) {
        _textCtrl.forward().then((_) {
          if (mounted) _loadingCtrl.forward();
        });
      }
    });
    // Reduced from 4s to 2.5s for faster transition
    _navigationTimer = Timer(
      const Duration(milliseconds: 2500),
      _navigateFromSplash,
    );
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
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ),
          );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _navigateFromSplash() async {
    if (!mounted) return;

    final updateInfo = await AppUpdateService.checkForUpdate();

    if (updateInfo.updateAvailable && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: !updateInfo.forceUpdate,
        builder: (_) => AppUpdateDialog(
          storeUrl: updateInfo.storeUrl,
          forceUpdate: updateInfo.forceUpdate,
          whatsNew: updateInfo.whatsNew,
          latestVersion: updateInfo.latestVersion,
        ),
      );
      if (updateInfo.forceUpdate) return;
    }

    if (!mounted) return;

    final token = await TokenStorage.getToken();
    final isValid = token != null && token.isNotEmpty
        ? await _isTokenValid(token)
        : false;
    if (!isValid) await TokenStorage.deleteToken();

    final destination = isValid ? const MainScreen() : const LoginScreen();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.995, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _orbCtrl.dispose();
    _glowCtrl.dispose();
    _dotsCtrl.dispose();
    _arcRotateCtrl.dispose();
    _loadingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Colors.background,
      body: Stack(
        children: [
          // Animated soft orbs
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (_, __) => _OrbsLayer(t: _orbCtrl.value),
          ),

          // Logo + arc ring + brand name — all in one centred column
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glow halo, arc ring, and logo card share the same centre
                SlideTransition(
                  position: _logoSlide,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _glowOpacity,
                            builder: (_, __) =>
                                _GlowHalo(opacity: _glowOpacity.value),
                          ),
                          _ArcRing(rotation: _arcRotation),
                          const _LogoCard(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SlideTransition(
                  position: _textSlide,
                  child: const _BrandText(),
                ),
              ],
            ),
          ),

          // Loading indicator
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _loadingSlide,
              child: FadeTransition(
                opacity: _loadingOpacity,
                child: Column(
                  children: [
                    _LoadingDots(controller: _dotsCtrl),
                    const SizedBox(height: 10),
                    Text(
                      'LOADING',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 3.5,
                        fontWeight: FontWeight.w500,
                        color: _Colors.goldDark.withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drifting orbs background
// ─────────────────────────────────────────────────────────────────────────────

class _OrbsLayer extends StatelessWidget {
  const _OrbsLayer({required this.t});

  final double t; // 0..1 repeating

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final angle = t * 2 * math.pi;

    return Stack(
      children: [
        // Large centred radial orb
        Positioned(
          left: size.width * 0.5 - size.width * 0.68,
          top: size.height * 0.18,
          child: Container(
            width: size.width * 1.36,
            height: size.width * 1.36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_Colors.orbBase, _Colors.background],
                stops: [0.35, 1.0],
              ),
            ),
          ),
        ),

        // Top-left drifting orb
        Positioned(
          left: size.width * (-0.12) + math.sin(angle) * size.width * 0.04,
          top: size.height * 0.04 + math.cos(angle) * size.height * 0.03,
          child: Container(
            width: size.width * 0.52,
            height: size.width * 0.52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _Colors.gold.withValues(alpha: 0.06),
            ),
          ),
        ),

        // Bottom-right drifting orb
        Positioned(
          right:
              size.width * (-0.10) + math.cos(angle + 1.0) * size.width * 0.04,
          bottom:
              size.height * 0.06 + math.sin(angle + 1.0) * size.height * 0.025,
          child: Container(
            width: size.width * 0.46,
            height: size.width * 0.46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _Colors.gold.withValues(alpha: 0.08),
            ),
          ),
        ),

        // Small top-right accent orb
        Positioned(
          right: size.width * 0.05 + math.sin(angle + 2.0) * size.width * 0.03,
          top: size.height * 0.10,
          child: Container(
            width: size.width * 0.22,
            height: size.width * 0.22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _Colors.gold.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ambient glow halo
// ─────────────────────────────────────────────────────────────────────────────

class _GlowHalo extends StatelessWidget {
  const _GlowHalo({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _Colors.gold.withValues(alpha: 0.42 * opacity),
            blurRadius: 90,
            spreadRadius: 24,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative sweep-gradient arc ring
// ─────────────────────────────────────────────────────────────────────────────

class _ArcRing extends StatelessWidget {
  const _ArcRing({required this.rotation});

  final Animation<double> rotation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotation,
      builder: (_, __) => Transform.rotate(
        angle: rotation.value,
        child: SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(painter: _ArcPainter()),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Colors.transparent,
          _Colors.gold,
          _Colors.goldLight,
          _Colors.gold,
          Colors.transparent,
        ],
        stops: [0.0, 0.15, 0.5, 0.85, 1.0],
      ).createShader(rect);

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2 - 2,
      ),
      -math.pi / 2,
      math.pi * 1.75,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo card (white circle, gold shadow, subtle pulse)
// ─────────────────────────────────────────────────────────────────────────────

class _LogoCard extends StatefulWidget {
  const _LogoCard();

  @override
  State<_LogoCard> createState() => _LogoCardState();
}

class _LogoCardState extends State<_LogoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.035,
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 148,
        height: 148,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _Colors.gold.withValues(alpha: 0.28),
              blurRadius: 50,
              spreadRadius: 6,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.95),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand text with gold gradient + decorative divider
// ─────────────────────────────────────────────────────────────────────────────

class _BrandText extends StatelessWidget {
  const _BrandText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_Colors.goldDark, _Colors.goldLight, _Colors.goldDark],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _thinLine(reverse: true),
            const SizedBox(width: 10),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _Colors.gold,
              ),
            ),
            const SizedBox(width: 10),
            _thinLine(reverse: false),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'YOUR TRUSTED SERVICE PARTNER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 3.0,
            color: _Colors.goldDark.withValues(alpha: 0.60),
          ),
        ),
      ],
    );
  }

  Widget _thinLine({required bool reverse}) => Container(
    width: 40,
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: reverse
            ? [_Colors.gold.withValues(alpha: 0.55), Colors.transparent]
            : [Colors.transparent, _Colors.gold.withValues(alpha: 0.55)],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated loading dots
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final start = i * 0.22;
            final end = (start + 0.50).clamp(0.0, 1.0);

            // Opacity animation
            final opacityAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: Interval(start, end, curve: Curves.easeInOut),
              ),
            );

            // Scale animation for more liveliness
            final scaleAnim = Tween<double>(begin: 0.6, end: 1.2).animate(
              CurvedAnimation(
                parent: controller,
                curve: Interval(start, end, curve: Curves.easeInOut),
              ),
            );

            // Vertical bounce
            final verticalAnim = Tween<double>(begin: 0.0, end: -8.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: Interval(start, end, curve: Curves.easeInOut),
              ),
            );

            return Transform.translate(
              offset: Offset(0, verticalAnim.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ScaleTransition(
                  scale: scaleAnim,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _Colors.gold.withValues(alpha: opacityAnim.value),
                      boxShadow: [
                        BoxShadow(
                          color: _Colors.gold.withValues(
                            alpha: opacityAnim.value * 0.4,
                          ),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
