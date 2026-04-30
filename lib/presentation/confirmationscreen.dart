import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sidi/models/booking_models.dart';
import 'package:sidi/presentation/mainscreen.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({
    super.key,
    required this.response,
    required this.serviceTitle,
    required this.serviceImage,
    required this.selectedTime,
    required this.selectedDate,

    this.stylistName,
    required this.stylistImage,
    this.stylistTag,
  });

  final BookingCreateResponse response;
  final String serviceTitle;
  final String serviceImage;
  final String selectedTime;
  final String selectedDate;
  final String? stylistName;
  final String? stylistImage;
  final String? stylistTag;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  void _retry() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final response = widget.response;
    if (!response.success) {
      return _buildError(
        message: response.message,
        context: context,
        showClose: true,
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                      semanticLabel: 'Back',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'BOOKING STATUS',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: screenHeight * 0.32, // Responsive height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          image: DecorationImage(
                            image: NetworkImage(
                              (widget.serviceImage.isNotEmpty)
                                  ? widget.serviceImage
                                  : 'https://via.placeholder.com/600x420',
                            ),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.48),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 18,
                              left: 18,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.88),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  'ARRIVING IN 30 MINS',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.6,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 24,
                              right: 24,
                              bottom: 24,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'On the way',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 34,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Your stylist is close and will arrive shortly.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.88),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage(
                                widget.stylistImage ??
                                    'https://i.pinimg.com/736x/f0/01/8d/f0018d672659d93315b051cf95246bb7.jpg',
                              ),
                              // foregroundImage: null,
                              // Accessibility label
                              child: Semantics(label: 'Stylist profile image'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.stylistName ?? 'Your Stylist',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.stylistTag ?? 'Beautician',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF8C8C8C),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     Container(
                            //       decoration: BoxDecoration(
                            //         border: Border.all(
                            //           color: const Color(0xFFDDD6C3),
                            //         ),
                            //         shape: BoxShape.circle,
                            //       ),
                            //       child: IconButton(
                            //         icon: const Icon(
                            //           Icons.chat_bubble_outline,
                            //           size: 18,
                            //           color: Color(0xFF1A1A1A),
                            //           semanticLabel: 'Chat',
                            //         ),
                            //         onPressed:
                            //             null, // Disabled until implemented
                            //         tooltip: 'Chat (coming soon)',
                            //       ),
                            //     ),
                            //     const SizedBox(width: 8),
                            //     Container(
                            //       decoration: BoxDecoration(
                            //         border: Border.all(
                            //           color: const Color(0xFFDDD6C3),
                            //         ),
                            //         shape: BoxShape.circle,
                            //       ),
                            //       child: IconButton(
                            //         icon: const Icon(
                            //           Icons.call,
                            //           size: 18,
                            //           color: Color(0xFF1A1A1A),
                            //           semanticLabel: 'Call',
                            //         ),
                            //         onPressed:
                            //             null, // Disabled until implemented
                            //         tooltip: 'Call (coming soon)',
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Booking Timeline removed
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 190,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC5A059),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'GO TO HOME',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Booking Timeline widget and method removed

  Widget _buildError({
    required String message,
    required BuildContext context,
    bool showClose = true,
  }) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showClose)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                Text(
                  'Booking failed',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B6B6B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retry,
                  child: Text(
                    'Retry',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
