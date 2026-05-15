import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import '../models/booking.dart';
import '../services/appointments_sync_service.dart';
import '../services/local_storage_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with WidgetsBindingObserver {
  static const String _fallbackImageUrl =
      'https://i.pinimg.com/1200x/8b/9a/ec/8b9aeceef93905e3b619889c2b0b7111.jpg';

  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastUpdatedAt;
  StreamSubscription<List<Booking>>? _bookingsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bookingsSubscription = AppointmentsSyncService.bookingsStream.listen(
      _applyIncomingBookings,
    );
    _loadBookings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bookingsSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_loadBookings());
    }
  }

  Future<void> _loadBookings() async {
    final cachedBookings = await LocalStorageService.loadCachedBookings();
    if (mounted && _bookings.isEmpty && cachedBookings.isNotEmpty) {
      setState(() {
        _bookings = cachedBookings;
        _isLoading = false;
        _lastUpdatedAt = DateTime.now();
      });
    } else if (mounted && _bookings.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await AppointmentsSyncService.syncBookings();
    if (!mounted) return;

    setState(() {
      _bookings = result.bookings;
      _isLoading = false;
      _errorMessage = result.success || result.bookings.isNotEmpty
          ? null
          : ((result.errorMessage?.isNotEmpty ?? false)
                ? result.errorMessage
                : 'Failed to load bookings. Please try again.');
      if (result.bookings.isNotEmpty) {
        _lastUpdatedAt = DateTime.now();
      }
    });
  }

  void _applyIncomingBookings(List<Booking> bookings) {
    if (!mounted) return;

    setState(() {
      _bookings = bookings;
      _isLoading = false;
      if (bookings.isNotEmpty) {
        _errorMessage = null;
        _lastUpdatedAt = DateTime.now();
      }
    });
  }

  Future<void> _refreshBookings() async {
    await HapticFeedback.mediumImpact();
    await _loadBookings();
    if (mounted) await HapticFeedback.selectionClick();
  }

  Future<void> _deleteBooking(String id) async {
    final updated = _bookings.where((b) => b.id != id).toList();
    setState(() => _bookings = updated);
    await LocalStorageService.saveCachedBookings(updated);
  }

  Future<bool> _cancelBooking(String id) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index < 0) return false;

    final booking = _bookings[index];
    final normalizedStatus = booking.status.trim().toLowerCase();
    if (normalizedStatus == 'cancelled' || normalizedStatus == 'completed') {
      return false;
    }

    final updatedBooking = Booking(
      id: booking.id,
      title: booking.title,
      time: booking.time,
      bookingDate: booking.bookingDate,
      serviceId: booking.serviceId,
      stylist: booking.stylist,
      image: booking.image,
      status: 'cancelled',
      jobId: booking.jobId,
    );

    final updatedBookings = [..._bookings];
    updatedBookings[index] = updatedBooking;

    setState(() {
      _bookings = updatedBookings;
      _lastUpdatedAt = DateTime.now();
    });

    await LocalStorageService.saveCachedBookings(updatedBookings);
    return true;
  }

  String _resolveImageUrl(String image) {
    if (image.isEmpty) return _fallbackImageUrl;
    if (image.startsWith('http')) return image;
    return 'https://sidi.mobilegear.co.in$image';
  }

  Future<void> _openAppointmentDetails(Booking booking) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AppointmentDetailPage(
          booking: booking,
          imageUrl: _resolveImageUrl(booking.image),
          statusColor: _statusColor(booking.status),
          onCancel: () => _cancelBooking(booking.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.82, 1.0);

    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: RefreshIndicator(
        onRefresh: _refreshBookings,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: kBackgroundLight,
              surfaceTintColor: kBackgroundLight,
              centerTitle: true,
              title: Text(
                'My Appointments',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: kCharcoalColor,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                10 * scale,
                16 * scale,
                24 * scale,
              ),
              sliver: SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    if (_isLoading) {
                      return const _AppointmentsLoadingState();
                    }
                    if (_errorMessage != null) {
                      return _AppointmentsErrorState(
                        message: _errorMessage!,
                        onRetry: _refreshBookings,
                      );
                    }
                    final bookings = _bookings;
                    if (bookings.isEmpty) {
                      return _AppointmentsEmptyState(
                        onRefresh: _refreshBookings,
                      );
                    }

                    // Split by date: recent = last 14 days or future, earlier = older
                    final recentCutoff = DateTime.now().subtract(
                      const Duration(days: 14),
                    );
                    final hasDateInfo = bookings.any(
                      (b) => b.bookingDate.isNotEmpty,
                    );
                    final recentBookings = hasDateInfo
                        ? bookings.where((b) {
                            final d = DateTime.tryParse(b.bookingDate);
                            return d == null || !d.isBefore(recentCutoff);
                          }).toList()
                        : bookings.take(2).toList();
                    final earlierBookings = hasDateInfo
                        ? bookings.where((b) {
                            final d = DateTime.tryParse(b.bookingDate);
                            return d != null && d.isBefore(recentCutoff);
                          }).toList()
                        : bookings.skip(2).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6 * scale),
                        Text(
                          'Appointments',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 36 * scale,
                            fontStyle: FontStyle.italic,
                            color: kCharcoalColor,
                          ),
                        ),
                        if (_lastUpdatedAt != null) ...[
                          SizedBox(height: 4 * scale),
                          Text(
                            'Last updated ${_formatLastUpdated(_lastUpdatedAt!)}',
                            style: GoogleFonts.inter(
                              fontSize: 11 * scale,
                              color: kWarmGrey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        SizedBox(height: 22 * scale),
                        _buildSectionLabel('RECENT', scale),
                        SizedBox(height: 6 * scale),
                        Divider(color: kWarmGrey200, height: 1),
                        SizedBox(height: 12 * scale),
                        ...recentBookings.map(
                          (b) => Dismissible(
                            key: ValueKey(b.id),
                            direction: DismissDirection.endToStart,
                            background: _buildDeleteBackground(scale),
                            onDismissed: (_) => _deleteBooking(b.id),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 12 * scale),
                              child: _AppearIn(
                                delayMs: 50,
                                child: _buildRecentAppointment(
                                  image: _resolveImageUrl(b.image),
                                  title: b.title,
                                  time: b.time,
                                  stylist: b.stylist,
                                  status: b.status,
                                  scale: scale,
                                  onTap: () => _openAppointmentDetails(b),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18 * scale),
                        if (earlierBookings.isNotEmpty) ...[
                          _buildSectionLabel('EARLIER', scale),
                          SizedBox(height: 6 * scale),
                          Divider(color: kWarmGrey200, height: 1),
                          SizedBox(height: 10 * scale),
                          ...earlierBookings.toList().asMap().entries.map(
                            (entry) => Dismissible(
                              key: ValueKey(entry.value.id),
                              direction: DismissDirection.endToStart,
                              background: _buildDeleteBackground(scale),
                              onDismissed: (_) =>
                                  _deleteBooking(entry.value.id),
                              child: _AppearIn(
                                delayMs: 90 + (entry.key * 40),
                                child: _buildEarlierAppointment(
                                  image: _resolveImageUrl(entry.value.image),
                                  title: entry.value.title,
                                  subtitle: entry.value.stylist,
                                  status: entry.value.status,
                                  scale: scale,
                                  onTap: () =>
                                      _openAppointmentDetails(entry.value),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteBackground(double scale) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20 * scale),
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFB03A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 22 * scale,
          ),
          SizedBox(height: 4 * scale),
          Text(
            'DELETE',
            style: GoogleFonts.inter(
              fontSize: 9 * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2D7A4F);
      case 'pending':
        return const Color(0xFFB8860B);
      case 'cancelled':
        return const Color(0xFFB03A2E);
      case 'completed':
        return const Color(0xFF1A5276);
      default:
        return kWarmGrey600;
    }
  }

  Widget _buildSectionLabel(String text, double scale) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: kCharcoalColor,
      ),
    );
  }

  Widget _buildRecentAppointment({
    required String image,
    required String title,
    required String time,
    required String stylist,
    required String status,
    required double scale,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.network(
              image,
              width: 66 * scale,
              height: 78 * scale,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 66 * scale,
                height: 78 * scale,
                color: Colors.grey[300],
                child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isNotEmpty ? title : 'No Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24 * scale,
                    fontStyle: FontStyle.italic,
                    color: kCharcoalColor,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  time.isNotEmpty ? time : 'No Time',
                  style: GoogleFonts.inter(
                    fontSize: 11 * scale,
                    color: kWarmGrey600,
                  ),
                ),
                if (status.isNotEmpty) ...[
                  SizedBox(height: 5 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 3 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withAlpha(28),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9 * scale,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: _statusColor(status),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 8 * scale),
                Text(
                  stylist.isNotEmpty ? stylist : 'No Stylist',
                  style: GoogleFonts.inter(
                    fontSize: 9 * scale,
                    letterSpacing: 1.6,
                    color: kWarmGrey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarlierAppointment({
    required String image,
    required String title,
    required String subtitle,
    required String status,
    required double scale,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12 * scale),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                width: 38 * scale,
                height: 38 * scale,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 38 * scale,
                  height: 38 * scale,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty ? title : 'No Title',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24 * scale,
                      fontStyle: FontStyle.italic,
                      color: kCharcoalColor,
                    ),
                  ),
                  Text(
                    subtitle.isNotEmpty ? subtitle : 'No Stylist',
                    style: GoogleFonts.inter(
                      fontSize: 10 * scale,
                      color: kWarmGrey600,
                    ),
                  ),
                  if (status.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 3 * scale),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6 * scale,
                          vertical: 2 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withAlpha(28),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 8 * scale,
                            fontWeight: FontWeight.w700,
                            color: _statusColor(status),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 8 * scale),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Browse the Home tab to find and rebook "$title".',
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: kCharcoalColor,
                side: BorderSide(color: kWarmGrey200),
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 7 * scale,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'REBOOK',
                style: GoogleFonts.inter(
                  fontSize: 9 * scale,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return 'at $hour:$minute $period';
  }
}

class _AppointmentDetailPage extends StatefulWidget {
  const _AppointmentDetailPage({
    required this.booking,
    required this.imageUrl,
    required this.statusColor,
    required this.onCancel,
  });

  final Booking booking;
  final String imageUrl;
  final Color statusColor;
  final Future<bool> Function() onCancel;

  @override
  State<_AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<_AppointmentDetailPage> {
  late String _status;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _status = widget.booking.status;
  }

  String _readableStatus(String raw) {
    if (raw.trim().isEmpty) return 'Unknown';
    final lower = raw.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  String _formatDate(String rawDate) {
    if (rawDate.trim().isEmpty) return 'Not specified';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekday[parsed.weekday - 1]}, ${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  String _formatTime(String rawTime) {
    return rawTime.trim().isEmpty ? 'Not specified' : rawTime;
  }

  Future<void> _confirmAndCancel() async {
    final canCancel =
        !(_status.trim().toLowerCase() == 'cancelled' ||
            _status.trim().toLowerCase() == 'completed');
    if (!canCancel || _isCancelling) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(125),
      builder: (context) {
        final title = widget.booking.title.isEmpty
            ? 'Appointment'
            : widget.booking.title;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFBF5), Color(0xFFF6EFE4)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 34,
                  offset: Offset(0, 20),
                ),
              ],
              border: Border.all(color: const Color(0xFFE9DDC8)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB03A2E).withAlpha(25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.event_busy_rounded,
                      color: Color(0xFFB03A2E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Cancel Appointment?',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 33,
                      fontStyle: FontStyle.italic,
                      height: 0.95,
                      color: kCharcoalColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You are about to cancel "$title". This action cannot be undone from this screen.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.35,
                      color: kWarmGrey600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(180),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8DECF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: Color(0xFF8A6F4D),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Status will be changed to CANCELLED.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: const Color(0xFF8A6F4D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kCharcoalColor,
                            side: BorderSide(color: kWarmGrey200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text(
                            'KEEP',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB03A2E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text(
                            'CONFIRM',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    final success = await widget.onCancel();
    if (!mounted) return;

    setState(() {
      _isCancelling = false;
      if (success) _status = 'cancelled';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Appointment cancelled successfully.'
              : 'Unable to cancel this appointment.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _metaTile({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kWarmGrey200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: kCharcoalColor),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                    color: kWarmGrey600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.trim().isEmpty ? 'Not available' : value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kCharcoalColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _readableStatus(_status);
    final statusColor = _status.trim().toLowerCase() == 'cancelled'
        ? const Color(0xFFB03A2E)
        : _status.trim().toLowerCase() == 'completed'
        ? const Color(0xFF1A5276)
        : widget.statusColor;
    final canCancel =
        !(_status.trim().toLowerCase() == 'cancelled' ||
            _status.trim().toLowerCase() == 'completed');

    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 280,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE6E3DE),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        color: Color(0xFF8C857E),
                        size: 44,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(30),
                          Colors.black.withAlpha(150),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: Text(
                      widget.booking.title.isEmpty
                          ? 'Appointment'
                          : widget.booking.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 36,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(28),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ),
                      Text(
                        'Booking ID: ${widget.booking.id.isEmpty ? 'N/A' : widget.booking.id}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: kWarmGrey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _metaTile(
                    label: 'DATE',
                    value: _formatDate(widget.booking.bookingDate),
                    icon: Icons.calendar_month_rounded,
                  ),
                  const SizedBox(height: 10),
                  _metaTile(
                    label: 'TIME',
                    value: _formatTime(widget.booking.time),
                    icon: Icons.schedule_rounded,
                  ),
                  const SizedBox(height: 10),
                  _metaTile(
                    label: 'STYLIST',
                    value: widget.booking.stylist.isEmpty
                        ? 'Not assigned'
                        : widget.booking.stylist,
                    icon: Icons.person_rounded,
                  ),
                  if (widget.booking.serviceId.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _metaTile(
                      label: 'SERVICE ID',
                      value: widget.booking.serviceId,
                      icon: Icons.content_cut_rounded,
                    ),
                  ],
                  if (widget.booking.jobId.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _metaTile(
                      label: 'JOB ID',
                      value: widget.booking.jobId,
                      icon: Icons.badge_rounded,
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: canCancel ? _confirmAndCancel : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB03A2E),
                        disabledBackgroundColor: kWarmGrey200,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: kWarmGrey600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isCancelling
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cancel_outlined, size: 16),
                      label: Text(
                        _isCancelling
                            ? 'CANCELLING...'
                            : (canCancel
                                  ? 'CANCEL APPOINTMENT'
                                  : 'CANNOT CANCEL'),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Browse Home to rebook this service.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kCharcoalColor,
                        side: BorderSide(color: kWarmGrey200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(
                        'REBOOK THIS SERVICE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}

class _AppearIn extends StatefulWidget {
  const _AppearIn({required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  State<_AppearIn> createState() => _AppearInState();
}

class _AppearInState extends State<_AppearIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.delayMs > 0) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, (1 - _animation.value) * 10),
        child: Transform.scale(
          scale: 0.97 + (_animation.value * 0.03),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

class _AppointmentsLoadingState extends StatelessWidget {
  const _AppointmentsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 84,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentsErrorState extends StatelessWidget {
  const _AppointmentsErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFF8A5F54),
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: kWarmGrey600),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _AppointmentsEmptyState extends StatelessWidget {
  const _AppointmentsEmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFF5EFE6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: Color(0xFF8A7A67),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No appointments yet',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kCharcoalColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Book your first service and it will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: kWarmGrey600),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
