// import 'package:flutter/material.dart';

// class LoadingButton extends StatefulWidget {
//   final Future<void> Function() onPressed;
//   final String text;
//   final Color color;
//   final double height;

//   const LoadingButton({
//     super.key,
//     required this.onPressed,
//     required this.text,
//     required this.color,
//     this.height = 54,
//   });

//   @override
//   State<LoadingButton> createState() => _LoadingButtonState();
// }

// class _LoadingButtonState extends State<LoadingButton> {
//   bool _isLoading = false;
//   double? _fullWidth;

//   Future<void> _handleTap() async {
//     if (_isLoading) return;

//     setState(() => _isLoading = true);

//     try {
//       await widget.onPressed();
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         _fullWidth ??= constraints.maxWidth;

//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           width: _isLoading ? widget.height : _fullWidth!,
//           height: widget.height,
//           decoration: BoxDecoration(
//             color: widget.color,
//             borderRadius: BorderRadius.circular(
//               _isLoading ? widget.height / 2 : 30,
//             ),
//           ),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(
//               _isLoading ? widget.height / 2 : 30,
//             ),
//             onTap: _handleTap,
//             child: Center(
//               child: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 200),
//                 transitionBuilder: (child, animation) =>
//                     FadeTransition(opacity: animation, child: child),
//                 child: _isLoading
//                     ? const SizedBox(
//                         key: ValueKey('loader'),
//                         width: 22,
//                         height: 22,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : Text(
//                         widget.text,
//                         key: const ValueKey('text'),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String text;
  final Color color;
  final double height;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
    this.height = 54,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  double? _fullWidth;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );

    _scaleAnimation = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLoading) return;

    await _scaleController.reverse();

    setState(() => _isLoading = true);

    await _scaleController.forward();

    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _fullWidth ??= constraints.maxWidth;

        return ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            width: _isLoading ? widget.height : _fullWidth!,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(
                _isLoading ? widget.height / 2 : 30,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: _isLoading ? 8 : 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(
                _isLoading ? widget.height / 2 : 30,
              ),
              onTap: _handleTap,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _isLoading
                      ? const _Loader(key: ValueKey('loader'))
                      : Text(
                          widget.text,
                          key: const ValueKey('text'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Loader extends StatefulWidget {
  const _Loader({super.key});

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
    );
  }
}
