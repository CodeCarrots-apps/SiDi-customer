import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['ALL', 'APPOINTMENTS', 'OFFERS'];
  final List<_NotificationEntry> _notifications = [
    _NotificationEntry(
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      message: 'Your session with Elena is confirmed for tomorrow at 2 PM.',
      icon: Icons.calendar_today_outlined,
      category: _NotificationCategory.appointments,
    ),
    _NotificationEntry(
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      message:
          'As a valued guest, enjoy 20% off your next \'Morning Glow\' facial.',
      icon: Icons.auto_awesome_outlined,
      category: _NotificationCategory.offers,
      actionLabel: 'CLAIM OFFER',
    ),
    _NotificationEntry(
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      message: 'Face ID verification is now active for your account.',
      icon: Icons.fingerprint,
      category: _NotificationCategory.other,
    ),
    _NotificationEntry(
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      message: 'Your monthly editorial journal is now available.',
      subtitle: 'Issue No. 14: The Winter Serenity Guide',
      imageUrl:
          'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=300&q=80',
      icon: Icons.menu_book_outlined,
      category: _NotificationCategory.other,
      isEditorial: true,
    ),
  ];

  void _clearNotifications() {
    setState(() {
      _notifications.clear();
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _isSameDay(date, yesterday);
  }

  String _relativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes.clamp(1, 59)}M AGO';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}H AGO';
    }
    if (diff.inDays == 1) {
      return 'YESTERDAY';
    }
    return '${diff.inDays}D AGO';
  }

  String _dayLabel(DateTime date) {
    if (_isYesterday(date)) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  List<_NotificationEntry> _sortedVisibleNotifications() {
    final selectedCategory = switch (_selectedFilterIndex) {
      1 => _NotificationCategory.appointments,
      2 => _NotificationCategory.offers,
      _ => null,
    };

    final list = _notifications
        .where(
          (n) => selectedCategory == null || n.category == selectedCategory,
        )
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: kBackgroundLight,
            surfaceTintColor: kBackgroundLight,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: kCharcoalColor,
                size: 18,
              ),
            ),
            centerTitle: true,
            title: Text(
              'NOTIFICATIONS',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: kCharcoalColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _notifications.isEmpty ? null : _clearNotifications,
                child: Text(
                  'CLEAR',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w500,
                    color: _notifications.isEmpty ? kWarmGrey200 : kAccentGold,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildFilters()),
          SliverToBoxAdapter(child: _buildNotificationFeed()),
        ],
      ),
    );
  }

  Widget _buildNotificationFeed() {
    final items = _sortedVisibleNotifications();

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 140),
        child: Center(
          child: Text(
            'No notifications to show.',
            style: GoogleFonts.inter(fontSize: 13, color: kWarmGrey600),
          ),
        ),
      );
    }

    final List<Widget> children = [];
    DateTime? previousDay;

    for (final item in items) {
      final currentDay = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );

      final shouldShowDayHeader =
          !_isToday(currentDay) &&
          (previousDay == null || !_isSameDay(previousDay, currentDay));

      if (shouldShowDayHeader) {
        children.add(const SizedBox(height: 38));
        children.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _dayLabel(currentDay),
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: kWarmGrey600,
              ),
            ),
          ),
        );
        children.add(const SizedBox(height: 22));
      }

      if (item.isEditorial) {
        children.add(_buildEditorialCard(item));
      } else {
        children.add(
          _buildNotificationCard(
            time: _relativeTime(item.createdAt),
            message: item.message,
            trailing: Icon(item.icon, size: 14, color: kWarmGrey200),
            actionLabel: item.actionLabel,
          ),
        );
      }

      previousDay = currentDay;
    }

    children.add(const SizedBox(height: 42));
    children.add(
      Text(
        'END OF RECENT UPDATES',
        style: GoogleFonts.inter(
          fontSize: 9,
          letterSpacing: 4,
          color: kWarmGrey200,
        ),
      ),
    );
    children.add(const SizedBox(height: 130));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: children),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
      child: Wrap(
        spacing: 18,
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _filters[index],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    letterSpacing: 1.8,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected ? kCharcoalColor : kWarmGrey600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 24,
                  height: 1.2,
                  color: isSelected ? kCharcoalColor : Colors.transparent,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String time,
    required String message,
    required Widget trailing,
    String? actionLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kWarmGrey200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    letterSpacing: 2.8,
                    color: kWarmGrey600,
                  ),
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.45,
                color: kCharcoalColor,
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: kEspressoColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditorialCard(_NotificationEntry item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kWarmGrey200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YESTERDAY',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    letterSpacing: 2.8,
                    color: kWarmGrey600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.45,
                    color: kCharcoalColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.subtitle ?? '',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: kWarmGrey600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 62,
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFF2B2B2B),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.network(item.imageUrl ?? '', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationCategory { appointments, offers, other }

class _NotificationEntry {
  const _NotificationEntry({
    required this.createdAt,
    required this.message,
    required this.icon,
    required this.category,
    this.actionLabel,
    this.subtitle,
    this.imageUrl,
    this.isEditorial = false,
  });

  final DateTime createdAt;
  final String message;
  final String? subtitle;
  final String? imageUrl;
  final String? actionLabel;
  final IconData icon;
  final _NotificationCategory category;
  final bool isEditorial;
}
