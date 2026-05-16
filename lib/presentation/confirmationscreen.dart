import 'package:flutter/material.dart';
import 'dart:async';

import 'package:sidi/constant/constants.dart';
import 'package:sidi/constant/app_fonts.dart';
import 'package:sidi/models/booking_models.dart';
import 'package:sidi/presentation/appointments_screen.dart';
import 'package:sidi/services/booking_service.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({
    super.key,
    required this.response,
    required this.serviceTitle,
    required this.serviceImage,
    required this.selectedTime,
    required this.selectedDate,
    this.servicePrice,
    this.stylistName,
    required this.stylistImage,
    this.stylistTag,
  });

  final BookingCreateResponse response;
  final String serviceTitle;
  final String serviceImage;
  final String selectedTime;
  final String selectedDate;
  final String? servicePrice;
  final String? stylistName;
  final String? stylistImage;
  final String? stylistTag;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  Timer? _statusPollingTimer;
  String _liveStatus = '';

  @override
  void initState() {
    super.initState();
    _liveStatus = widget.response.booking?.status ?? '';
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusPollingTimer?.cancel();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goToAppointments() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
  }

  void _retry() {
    Navigator.pop(context);
  }

  void _startStatusPolling() {
    final bookingId = widget.response.booking?.id;
    if (bookingId == null || bookingId.isEmpty) return;

    _syncBookingStatus();
    _statusPollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _syncBookingStatus();
    });
  }

  Future<void> _syncBookingStatus() async {
    final bookingId = widget.response.booking?.id;
    if (bookingId == null || bookingId.isEmpty || !mounted) return;

    final response = await BookingService.getBookingDetails(bookingId);
    if (!mounted || !response.success || response.booking == null) return;

    final nextStatus = response.booking!.status;
    if (nextStatus.trim().isEmpty || nextStatus == _liveStatus) return;

    setState(() {
      _liveStatus = nextStatus;
    });
  }

  ({String label, Color color, IconData icon}) _statusChipFor(String status) {
    final normalized = status.toLowerCase().trim();
    if (normalized == 'accepted' || normalized == 'assigned') {
      return (
        label: 'BOOKING CONFIRMED',
        color: const Color(0xFF2D7A4F),
        icon: Icons.check_circle_rounded,
      );
    }
    if (normalized == 'requested' ||
        normalized == 'pending' ||
        normalized == 'waiting' ||
        normalized == 'waitlist' ||
        normalized == 'waiting_list' ||
        normalized == 'queued' ||
        normalized == 'queue') {
      return (
        label: 'WAITING FOR ASSIGNMENT',
        color: const Color(0xFFB07A1A),
        icon: Icons.hourglass_top_rounded,
      );
    }
    if (normalized == 'cancelled' || normalized == 'rejected') {
      return (
        label: 'BOOKING NOT ACTIVE',
        color: const Color(0xFFC44747),
        icon: Icons.cancel_rounded,
      );
    }
    if (normalized == 'completed') {
      return (
        label: 'SERVICE COMPLETED',
        color: const Color(0xFF356EAF),
        icon: Icons.verified_rounded,
      );
    }
    return (
      label: 'BOOKING STATUS LIVE',
      color: const Color(0xFF5B6470),
      icon: Icons.sync_rounded,
    );
  }

  String _readableStatus(String status) {
    final cleaned = status.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return 'Requested';
    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
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

    final liveStatus = _liveStatus.isNotEmpty
        ? _liveStatus
        : (response.booking?.status.isNotEmpty == true
              ? response.booking!.status
              : 'accepted');
    final statusChip = _statusChipFor(liveStatus);
    final statusDateText = '${widget.selectedDate}  ·  ${widget.selectedTime}';
    final bookingId = widget.response.booking?.id ?? '';

    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        _goHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F5EE),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _goHome,
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black87,
                        semanticLabel: 'Back',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'BOOKING STATUS',
                      style: AppFonts.inter(
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
                                      Colors.black.withOpacity(0.60),
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
                                    color: statusChip.color.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        statusChip.icon,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        statusChip.label,
                                        style: AppFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.4,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
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
                                      widget.serviceTitle,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.playfairDisplay(
                                        fontSize: 28,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 13,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          statusDateText,
                                          style: AppFonts.inter(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(
                                              0.88,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Live status: ${_readableStatus(liveStatus)}',
                                      style: AppFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.82),
                                        fontWeight: FontWeight.w500,
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
                                child: Semantics(
                                  label: 'Stylist profile image',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.stylistName ?? 'Your Stylist',
                                      style: AppFonts.playfairDisplay(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.stylistTag ?? 'Beautician',
                                      style: AppFonts.inter(
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
                      const SizedBox(height: 32),
                      // Booking reference
                      if (bookingId.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F0E8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE8E2D8),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.confirmation_number_outlined,
                                  size: 16,
                                  color: kChampagneColor,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Booking Ref:  ',
                                  style: AppFonts.inter(
                                    fontSize: 12,
                                    color: kWarmGrey600,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    bookingId,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: kEspressoColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          onPressed: _goHome,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC5A059),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'GO TO HOME',
                            style: AppFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton(
                          onPressed: _goToAppointments,
                          child: Text(
                            'VIEW MY APPOINTMENTS',
                            style: AppFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: kChampagneColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                  style: AppFonts.cormorantGaramond(
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B6B6B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retry,
                  child: Text(
                    'Go Back',
                    style: AppFonts.inter(fontWeight: FontWeight.w600),
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
