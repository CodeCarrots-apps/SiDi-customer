import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import '../models/booking.dart';
import '../services/local_storage_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastUpdatedAt;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final bookings = await LocalStorageService.loadCachedBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _isLoading = false;
        _lastUpdatedAt = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load bookings. Please try again.';
      });
    }
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
                                  image: b.image.isNotEmpty
                                      ? b.image
                                      : 'https://i.pinimg.com/1200x/8b/9a/ec/8b9aeceef93905e3b619889c2b0b7111.jpg',
                                  title: b.title,
                                  time: b.time,
                                  stylist: b.stylist,
                                  status: b.status,
                                  scale: scale,
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
                                  image: entry.value.image.isNotEmpty
                                      ? (entry.value.image.startsWith('http')
                                            ? entry.value.image
                                            : 'https://sidi.mobilegear.co.in${entry.value.image}')
                                      : 'https://i.pinimg.com/1200x/8b/9a/ec/8b9aeceef93905e3b619889c2b0b7111.jpg',
                                  title: entry.value.title,
                                  subtitle: entry.value.stylist,
                                  status: entry.value.status,
                                  scale: scale,
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
  }) {
    return Row(
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
    );
  }

  Widget _buildEarlierAppointment({
    required String image,
    required String title,
    required String subtitle,
    required String status,
    required double scale,
  }) {
    return Padding(
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
                child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
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
    );
  }

  String _formatLastUpdated(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return 'at $hour:$minute $period';
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
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 10),
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
