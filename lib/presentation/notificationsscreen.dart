import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sidi/constant/app_fonts.dart';
import 'package:sidi/constant/constants.dart';

import '../models/app_notification.dart';
import '../services/appointments_sync_service.dart';
import '../services/local_storage_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0;
  bool _isLoading = true;
  StreamSubscription<List<AppNotification>>? _notificationsSubscription;

  final List<String> _filters = ['ALL', 'APPOINTMENTS', 'UPDATES'];
  List<AppNotification> _notifications = const [];

  @override
  void initState() {
    super.initState();
    _notificationsSubscription = AppointmentsSyncService.notificationsStream
        .listen(_applyNotifications);
    _loadNotifications();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final storedNotifications =
        await LocalStorageService.loadAppNotifications();
    if (!mounted) return;

    setState(() {
      _notifications = storedNotifications;
      _isLoading = false;
    });

    await AppointmentsSyncService.publishNotifications();
  }

  void _applyNotifications(List<AppNotification> notifications) {
    if (!mounted) return;

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  Future<void> _clearNotifications() async {
    await AppointmentsSyncService.clearNotifications();
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

  List<AppNotification> _sortedVisibleNotifications() {
    final selectedCategory = switch (_selectedFilterIndex) {
      1 => AppNotificationCategory.appointments,
      2 => AppNotificationCategory.updates,
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
              style: AppFonts.cormorantGaramond(
                fontSize: 22,
                fontStyle: FontStyle.normal,
                color: kCharcoalColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _notifications.isEmpty ? null : _clearNotifications,
                child: Text(
                  'CLEAR',
                  style: AppFonts.inter(
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

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(24, 40, 24, 140),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 140),
        child: Center(
          child: Text(
            'No notifications to show.',
            style: AppFonts.inter(fontSize: 13, color: kWarmGrey600),
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
              style: AppFonts.cormorantGaramond(
                fontSize: 18,
                fontStyle: FontStyle.normal,
                color: kWarmGrey600,
              ),
            ),
          ),
        );
        children.add(const SizedBox(height: 22));
      }

      children.add(
        _buildNotificationCard(
          time: _relativeTime(item.createdAt),
          title: item.title,
          message: item.message,
          trailing: Icon(
            _notificationIcon(item.category),
            size: 16,
            color: kWarmGrey200,
          ),
        ),
      );

      previousDay = currentDay;
    }

    children.add(const SizedBox(height: 42));
    children.add(
      Text(
        'END OF RECENT UPDATES',
        style: AppFonts.inter(
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
                  style: AppFonts.inter(
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
    required String title,
    required String message,
    required Widget trailing,
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
                  style: AppFonts.inter(
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
          Text(
            title,
            style: AppFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: kWarmGrey600,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Text(
              message,
              style: AppFonts.inter(
                fontSize: 14,
                height: 1.45,
                color: kCharcoalColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _notificationIcon(AppNotificationCategory category) {
    switch (category) {
      case AppNotificationCategory.appointments:
        return Icons.calendar_today_outlined;
      case AppNotificationCategory.updates:
        return Icons.notifications_active_outlined;
    }
  }
}
