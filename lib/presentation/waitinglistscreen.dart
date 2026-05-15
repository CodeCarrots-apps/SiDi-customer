import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/booking_models.dart';
import 'package:sidi/models/service_cart_item.dart';
import 'package:sidi/presentation/mainscreen.dart';
import 'package:sidi/presentation/confirmationscreen.dart';
import 'package:sidi/services/booking_service.dart';
import 'dart:async';

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({
    super.key,
    required this.response,
    required this.serviceTitle,
    required this.serviceImage,
    required this.selectedTime,
    required this.selectedDate,
    this.stylistName,
    this.stylistImage,
    this.stylistTag,
    this.services = const [],
  });

  final BookingCreateResponse response;
  final String serviceTitle;
  final String serviceImage;
  final String selectedTime;
  final String selectedDate;
  final String? stylistName;
  final String? stylistImage;
  final String? stylistTag;
  final List<ServiceCartItem> services;

  @override
  State<WaitingListScreen> createState() => _WaitingListScreenState();
}

class _WaitingListScreenState extends State<WaitingListScreen>
    with TickerProviderStateMixin {
  Timer? _pollingTimer;
  dynamic _assignedBeautician;
  bool _isAssigned = false;
  String _statusMessage = 'Waiting for beautician...';
  late AnimationController _pulseController;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _startPolling() {
    if (widget.response.booking?.id.isEmpty ?? true) return;

    // Initial check
    _checkBookingStatus();

    // Poll every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkBookingStatus();
    });
  }

  Future<void> _checkBookingStatus() async {
    if (!mounted) return;

    final response = await BookingService.getBookingDetails(
      widget.response.booking!.id,
    );

    if (!mounted) return;

    if (response.success && response.booking != null) {
      debugPrint(
        '[WaitingListScreen] Booking status: ${response.booking!.status}',
      );

      // Check if beautician is assigned
      if (response.booking!.status.toLowerCase() == 'accepted' ||
          response.booking!.status.toLowerCase() == 'assigned') {
        if (_assignedBeautician == null) {
          // Beautician just assigned!
          _onBeauticianAssigned(response.booking!.status);
        }
      }
    }
  }

  void _onBeauticianAssigned(String status) {
    _pollingTimer?.cancel();

    setState(() {
      _isAssigned = true;
      _statusMessage = 'Beautician assigned!';
    });

    _successController.forward();

    // Wait 2 seconds for animation, then navigate
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ConfirmationScreen(
              response: widget.response,
              serviceTitle: widget.serviceTitle,
              serviceImage: widget.serviceImage,
              selectedTime: widget.selectedTime,
              selectedDate: widget.selectedDate,
              servicePrice: widget.response.estimatedPrice?.toString() ?? 'N/A',
              stylistName: widget.stylistName,
              stylistImage: widget.stylistImage,
              stylistTag: widget.stylistTag,
            ),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _isAssigned ? 'BOOKING CONFIRMED' : 'WAITING LIST STATUS',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: 20),
                      if (!_isAssigned)
                        _buildLivePollingStatus()
                      else
                        _buildSuccessStatus(),
                      const SizedBox(height: 20),
                      _buildWaitingInfo(),
                      if (widget.services.length > 1) ...[
                        const SizedBox(height: 20),
                        _buildServicesCard(),
                      ],
                      const SizedBox(height: 20),
                      _buildStylistPreview(),
                      const SizedBox(height: 20),
                      if (widget.response.booking?.id.isNotEmpty == true)
                        _buildBookingRef(widget.response.booking!.id),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB07A1A),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          _isAssigned ? 'CONFIRM' : 'GOT IT',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(initialTab: 1),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'CHECK REQUEST STATUS',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.3,
                            color: const Color(0xFFB07A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePollingStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDD9F5)),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.2).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finding your beautician',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusMessage,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStatus() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beautician assigned!',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF047857),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your appointment has been confirmed',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF34D399),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(
            widget.serviceImage.isNotEmpty
                ? widget.serviceImage
                : 'https://via.placeholder.com/600x420',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
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
                  Colors.black.withAlpha(0),
                  Colors.black.withAlpha(150),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFB07A1A).withAlpha(235),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'WAITING LIST',
                    style: GoogleFonts.inter(
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
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.selectedDate}  ·  Requested ${widget.selectedTime}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withAlpha(225),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFD9B6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isAssigned
                    ? Icons.check_circle_rounded
                    : Icons.hourglass_top_rounded,
                size: 18,
                color: _isAssigned
                    ? const Color(0xFF10B981)
                    : const Color(0xFFB07A1A),
              ),
              const SizedBox(width: 8),
              Text(
                _isAssigned
                    ? 'Beautician confirmed!'
                    : 'You are on the waiting list',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6D4A10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isAssigned
                ? 'Your beautician has accepted your request and will arrive at the scheduled time.'
                : 'We are finding the best available beautician for your requested time slot. You will be notified once your appointment is confirmed.',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.5,
              color: const Color(0xFF7B5D2A),
            ),
          ),
          if (!_isAssigned && (widget.response.broadcastedCount ?? 0) > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Text(
                    '●',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Request sent to ${widget.response.broadcastedCount} nearby stylists',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8A672B),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E2D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requested Services',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              color: kEspressoColor,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB07A1A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      service.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kEspressoColor,
                      ),
                    ),
                  ),
                  if (service.price.isNotEmpty)
                    Text(
                      service.price,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: kWarmGrey600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStylistPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
            child: Semantics(label: 'Stylist profile image'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.stylistName ??
                      (_isAssigned
                          ? 'Beautician assigned'
                          : 'Assigning stylist...'),
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
        ],
      ),
    );
  }

  Widget _buildBookingRef(String bookingId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E2D8)),
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
            style: GoogleFonts.inter(fontSize: 12, color: kWarmGrey600),
          ),
          Expanded(
            child: Text(
              bookingId,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kEspressoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
