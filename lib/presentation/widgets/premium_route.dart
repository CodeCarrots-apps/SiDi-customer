import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Splash-style route overlay used for detail-screen navigation.
/// Keeps the splash visual language (orbs, gold arc ring, logo card, dots).
class PremiumPageRoute<T> extends PageRouteBuilder<T> {
  PremiumPageRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 380),
        // Longer reverse so the eye can track the page leaving — 260ms felt
        // like a sudden crush because the scale + slide compounded too fast.
        reverseTransitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _PremiumShell(destinationBuilder: builder),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final isForward = animation.status != AnimationStatus.reverse;

          if (isForward) {
            // Enter: subtle upward slide + micro-scale in.
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
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
          } else {
            // Exit: slide down and fade out — no scale, so there is no
            // "shrinking container" artifact. easeInOut gives the motion a
            // natural arc so it doesn't feel abrupt or laggy.
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
                child: child,
              ),
            );
          }
        },
      );
}

abstract final class _Colors {
  static const background = Color(0xFFFDFCF8);
  static const gold = Color(0xFFD9AE60);
  static const goldLight = Color(0xFFF0D498);
  static const orbBase = Color(0xFFFAF5E9);
}

class _PremiumShell extends StatefulWidget {
  final WidgetBuilder destinationBuilder;
  const _PremiumShell({required this.destinationBuilder});

  @override
  State<_PremiumShell> createState() => _PremiumShellState();
}

class _PremiumShellState extends State<_PremiumShell>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _logoScale = Tween<double>(
    begin: 0.72,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
  late final Animation<Offset> _logoSlide = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));

  late final AnimationController _orbCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);
  late final Animation<double> _glowOpacity = Tween<double>(
    begin: 0.28,
    end: 0.72,
  ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

  // FIX: full 2-second revolution so the dot and gradient sweep stay in sync.
  late final AnimationController _ringCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat();

  late final AnimationController _exitCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  bool _overlayVisible = true;

  static const Duration _displayDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _logoCtrl.forward();

    Future.delayed(_displayDuration, () {
      if (!mounted) return;
      // FIX: stop looping controllers before the fade so they don't keep
      // scheduling repaints after the overlay is gone.
      _orbCtrl.stop();
      _glowCtrl.stop();
      _ringCtrl.stop();
      _exitCtrl.forward().then((_) {
        if (mounted) setState(() => _overlayVisible = false);
      });
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _orbCtrl.dispose();
    _glowCtrl.dispose();
    _ringCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.destinationBuilder(context),
        if (_overlayVisible)
          AnimatedBuilder(
            animation: _exitCtrl,
            builder: (_, __) {
              final exitT = Curves.easeInCubic.transform(_exitCtrl.value);
              // Fade the whole overlay as a single composited layer so the
              // glow's circular box-shadow never renders against a transparent
              // background (which caused the visible ring artifact on exit).
              return Opacity(
                opacity: (1.0 - exitT).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, -6 * exitT),
                  child: ColoredBox(
                    color: _Colors.background,
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _orbCtrl,
                          builder: (_, __) => _OrbsLayer(t: _orbCtrl.value),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                          builder: (_, __) => _GlowHalo(
                                            opacity: _glowOpacity.value,
                                          ),
                                        ),
                                        const _ArcRing(),
                                        AnimatedBuilder(
                                          animation: _ringCtrl,
                                          builder: (_, __) => _LoadingOrbitRing(
                                            progress: _ringCtrl.value,
                                          ),
                                        ),
                                        const _LogoCard(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _OrbsLayer extends StatelessWidget {
  const _OrbsLayer({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final angle = t * 2 * math.pi;

    return Stack(
      children: [
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

class _ArcRing extends StatelessWidget {
  const _ArcRing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(painter: _ArcPainter()),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // FIX: rotate the canvas so the SweepGradient's 0° (3 o'clock) aligns
    // with the arc's startAngle of -π/2 (12 o'clock).
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-center.dx, -center.dy);

    final rect = Rect.fromCircle(center: center, radius: radius);
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
      rect,
      0, // starts at 3 o'clock in rotated space == 12 o'clock on screen
      math.pi * 1.75,
      false,
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _Colors.gold.withValues(alpha: 0.34),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _Colors.gold.withValues(alpha: 0.22),
              blurRadius: 42,
              spreadRadius: 4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
    );
  }
}

class _LoadingOrbitRing extends StatelessWidget {
  const _LoadingOrbitRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 184,
      height: 184,
      child: CustomPaint(painter: _LoadingOrbitPainter(progress: progress)),
    );
  }
}

class _LoadingOrbitPainter extends CustomPainter {
  const _LoadingOrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _Colors.gold.withValues(alpha: 0.13);

    canvas.drawCircle(center, radius, trackPaint);

    // FIX: use a full 2π sweep so the dot (which travels the full circle)
    // always sits at the bright leading edge of the gradient trail.
    // The GradientRotation offsets the shader to match the dot's angle.
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          _Colors.gold.withValues(alpha: 0.0),
          _Colors.gold.withValues(alpha: 0.95),
          _Colors.goldLight.withValues(alpha: 0.85),
          _Colors.gold.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.42, 0.72, 1.0],
        // Rotate the gradient so the bright tip leads the dot.
        transform: GradientRotation(progress * 2 * math.pi - math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw the full orbit so the gradient covers the entire ring.
    canvas.drawCircle(center, radius, arcPaint);

    // Dot travels the full circle, starting at 12 o'clock (-π/2).
    final dotAngle = -math.pi / 2 + progress * 2 * math.pi;
    final dotOffset = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );

    canvas.drawCircle(
      dotOffset,
      3.0,
      Paint()..color = _Colors.goldLight.withValues(alpha: 0.92),
    );
  }

  @override
  bool shouldRepaint(covariant _LoadingOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
