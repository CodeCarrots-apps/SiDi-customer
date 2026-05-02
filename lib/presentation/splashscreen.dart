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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sidi/presentation/loginscreen.dart';
import 'package:sidi/presentation/mainscreen.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sidi/utils/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Color backgroundColor = Color(0xFFFDFCF8);
  static const Color haloColor = Color(0xFFFAF5E9);
  static const Color brandGold = Color(0xFFD9AE60);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navigationTimer;

  late AnimationController _logoController;
  late AnimationController _haloController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _haloRotation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _haloRotation = Tween<double>(begin: 0, end: 1).animate(_haloController);

    _logoController.forward();

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

    final token = await TokenStorage.getToken();
    final isValid = token != null && token.isNotEmpty
        ? await _isTokenValid(token)
        : false;

    if (!isValid) {
      await TokenStorage.deleteToken();
    }

    final destination = isValid ? const MainScreen() : const LoginScreen();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => destination,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.0).animate(animation),
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
    _logoController.dispose();
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashScreen.backgroundColor,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _haloRotation,
            builder: (_, _) {
              return Transform.rotate(
                angle: _haloRotation.value * 2 * 3.1416,
                child: const _SplashBackdrop(),
              );
            },
          ),
          Center(
            child: FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: const _LogoGlyph(),
              ),
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
    final circleSize = size.width * 1.5;

    return Center(
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: const BoxDecoration(
          color: SplashScreen.haloColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _LogoGlyph extends StatefulWidget {
  const _LogoGlyph();

  @override
  State<_LogoGlyph> createState() => _LogoGlyphState();
}

class _LogoGlyphState extends State<_LogoGlyph>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: SplashScreen.brandGold.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SizedBox(
          height: 200,
          width: 200,
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
