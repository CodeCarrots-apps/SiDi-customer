import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/app_notification.dart';
import '../models/booking.dart';
import 'booking_service.dart';
import 'local_notifications_service.dart';
import 'local_storage_service.dart';

class AppointmentSyncResult {
  const AppointmentSyncResult({
    required this.bookings,
    required this.success,
    this.errorMessage,
  });

  final List<Booking> bookings;
  final bool success;
  final String? errorMessage;
}

class AppointmentsSyncService {
  static const Duration _foregroundPollInterval = Duration(seconds: 20);
  static const Duration _notificationDedupWindow = Duration(minutes: 10);
  static final StreamController<List<Booking>> _bookingsController =
      StreamController<List<Booking>>.broadcast();
  static final StreamController<List<AppNotification>>
  _notificationsController =
      StreamController<List<AppNotification>>.broadcast();

  static Timer? _pollingTimer;
  static bool _initialized = false;
  static bool _syncInProgress = false;

  static Stream<List<Booking>> get bookingsStream => _bookingsController.stream;
  static Stream<List<AppNotification>> get notificationsStream =>
      _notificationsController.stream;

  static Future<void> initialize() async {
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();
    await LocalNotificationsService.initialize();
    await _emitCachedState();

    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiresBatteryNotLow: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout,
    );

    _startForegroundPolling();
    await syncBookings();
    _initialized = true;
  }

  static Future<AppointmentSyncResult> syncBookings({
    bool fromBackground = false,
    bool manualRefresh = false,
  }) async {
    if (_syncInProgress) {
      final cachedBookings = await LocalStorageService.loadCachedBookings();
      return AppointmentSyncResult(bookings: cachedBookings, success: true);
    }

    _syncInProgress = true;
    try {
      final cachedBookings = await LocalStorageService.loadCachedBookings();
      final wasSeeded = await LocalStorageService.hasSeededBookingSync();
      final response = await BookingService.getMyBookings(page: 1, limit: 50);

      if (!response.success) {
        _bookingsController.add(cachedBookings);
        return AppointmentSyncResult(
          bookings: cachedBookings,
          success: false,
          errorMessage: response.message,
        );
      }

      final nextBookings = response.bookings;
      await LocalStorageService.saveCachedBookings(nextBookings);
      _bookingsController.add(nextBookings);

      if (wasSeeded) {
        final notifications = _buildNotifications(
          previousBookings: cachedBookings,
          nextBookings: nextBookings,
        );
        if (notifications.isNotEmpty) {
          final existingNotifications =
              await LocalStorageService.loadAppNotifications();
          final uniqueIncomingNotifications = _uniqueIncomingNotifications(
            existing: existingNotifications,
            incoming: notifications,
          );
          final trimmedNotifications = _mergeNotifications(
            existing: existingNotifications,
            incoming: uniqueIncomingNotifications,
          );

          await LocalStorageService.saveAppNotifications(trimmedNotifications);
          _notificationsController.add(trimmedNotifications);

          if (fromBackground ||
              manualRefresh ||
              !listEquals(cachedBookings, nextBookings)) {
            for (final notification in uniqueIncomingNotifications) {
              await LocalNotificationsService.show(notification);
            }
          }
        }
      } else {
        await LocalStorageService.setBookingSyncSeeded();
      }

      return AppointmentSyncResult(bookings: nextBookings, success: true);
    } catch (error) {
      final cachedBookings = await LocalStorageService.loadCachedBookings();
      _bookingsController.add(cachedBookings);
      return AppointmentSyncResult(
        bookings: cachedBookings,
        success: false,
        errorMessage: 'Failed to sync appointments.',
      );
    } finally {
      _syncInProgress = false;
    }
  }

  static Future<void> clearNotifications() async {
    await LocalStorageService.clearAppNotifications();
    _notificationsController.add(const []);
  }

  static Future<void> publishNotifications() async {
    _notificationsController.add(
      await LocalStorageService.loadAppNotifications(),
    );
  }

  static Future<void> notifyBookingEvent({
    required Booking booking,
    required bool isWaitingList,
  }) async {
    final normalizedBooking = Booking(
      id: booking.id,
      title: booking.title,
      time: booking.time,
      bookingDate: booking.bookingDate,
      serviceId: booking.serviceId,
      stylist: booking.stylist,
      image: booking.image,
      status: booking.status,
      jobId: booking.jobId,
    );

    final cachedBookings = await LocalStorageService.loadCachedBookings();
    final bookingIndex = cachedBookings.indexWhere(
      (item) => item.id == normalizedBooking.id,
    );
    if (bookingIndex >= 0) {
      cachedBookings[bookingIndex] = normalizedBooking;
    } else {
      cachedBookings.insert(0, normalizedBooking);
    }

    await LocalStorageService.saveCachedBookings(cachedBookings);
    _bookingsController.add(cachedBookings);

    final title = isWaitingList
        ? 'Booking request submitted'
        : 'Appointment confirmed';
    final message = isWaitingList
        ? _buildWaitingListMessage(normalizedBooking)
        : _buildConfirmedMessage(normalizedBooking);

    final notification = AppNotification(
      id: 'booking-flow-${isWaitingList ? 'waiting' : 'confirmed'}-${normalizedBooking.id}-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      message: message,
      createdAt: DateTime.now(),
      category: AppNotificationCategory.appointments,
      bookingId: normalizedBooking.id,
    );

    final existingNotifications =
        await LocalStorageService.loadAppNotifications();
    final uniqueIncomingNotifications = _uniqueIncomingNotifications(
      existing: existingNotifications,
      incoming: [notification],
    );
    final trimmedNotifications = _mergeNotifications(
      existing: existingNotifications,
      incoming: uniqueIncomingNotifications,
    );

    await LocalStorageService.saveAppNotifications(trimmedNotifications);
    _notificationsController.add(trimmedNotifications);
    for (final item in uniqueIncomingNotifications) {
      await LocalNotificationsService.show(item);
    }
  }

  static String _notificationKey(AppNotification notification) {
    return [
      notification.category.name,
      notification.bookingId ?? '',
      notification.title.trim().toLowerCase(),
      notification.message.trim().toLowerCase(),
    ].join('|');
  }

  static List<AppNotification> _mergeNotifications({
    required List<AppNotification> existing,
    required List<AppNotification> incoming,
  }) {
    final combined = [...incoming, ...existing]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latestByKey = <String, DateTime>{};
    final merged = <AppNotification>[];

    for (final notification in combined) {
      final key = _notificationKey(notification);
      final lastKeptAt = latestByKey[key];
      final isDuplicateWithinWindow =
          lastKeptAt != null &&
          lastKeptAt.difference(notification.createdAt) <=
              _notificationDedupWindow;

      if (isDuplicateWithinWindow) {
        continue;
      }

      latestByKey[key] = notification.createdAt;
      merged.add(notification);

      if (merged.length >= 100) {
        break;
      }
    }

    return merged;
  }

  static List<AppNotification> _uniqueIncomingNotifications({
    required List<AppNotification> existing,
    required List<AppNotification> incoming,
  }) {
    if (incoming.isEmpty) return const [];

    final existingMerged = _mergeNotifications(
      existing: existing,
      incoming: const [],
    );
    final mergedWithIncoming = _mergeNotifications(
      existing: existing,
      incoming: incoming,
    );

    final existingIds = existingMerged.map((item) => item.id).toSet();
    final incomingIds = incoming.map((item) => item.id).toSet();

    return mergedWithIncoming.where((item) {
      return incomingIds.contains(item.id) && !existingIds.contains(item.id);
    }).toList();
  }

  static void _startForegroundPolling() {
    _pollingTimer ??= Timer.periodic(_foregroundPollInterval, (_) {
      unawaited(syncBookings());
    });
  }

  static Future<void> _emitCachedState() async {
    _bookingsController.add(await LocalStorageService.loadCachedBookings());
    _notificationsController.add(
      await LocalStorageService.loadAppNotifications(),
    );
  }

  static List<AppNotification> _buildNotifications({
    required List<Booking> previousBookings,
    required List<Booking> nextBookings,
  }) {
    final previousById = {
      for (final booking in previousBookings) booking.id: booking,
    };
    final notifications = <AppNotification>[];
    final timestamp = DateTime.now();

    for (final booking in nextBookings) {
      final previous = previousById[booking.id];
      if (previous == null) {
        notifications.add(
          AppNotification(
            id: 'booking-new-${booking.id}-${timestamp.microsecondsSinceEpoch}',
            title: 'New appointment added',
            message: _buildNewBookingMessage(booking),
            createdAt: timestamp,
            category: AppNotificationCategory.appointments,
            bookingId: booking.id,
          ),
        );
        continue;
      }

      if (previous.status != booking.status && booking.status.isNotEmpty) {
        notifications.add(
          AppNotification(
            id: 'booking-status-${booking.id}-${timestamp.microsecondsSinceEpoch}',
            title: 'Appointment status updated',
            message: _buildStatusMessage(booking),
            createdAt: timestamp,
            category: AppNotificationCategory.appointments,
            bookingId: booking.id,
          ),
        );
      }

      if (previous.bookingDate != booking.bookingDate ||
          previous.time != booking.time ||
          previous.stylist != booking.stylist) {
        notifications.add(
          AppNotification(
            id: 'booking-change-${booking.id}-${timestamp.microsecondsSinceEpoch}',
            title: 'Appointment updated',
            message: _buildScheduleMessage(booking),
            createdAt: timestamp,
            category: AppNotificationCategory.appointments,
            bookingId: booking.id,
          ),
        );
      }
    }

    return notifications;
  }

  static String _buildNewBookingMessage(Booking booking) {
    final serviceName = booking.title.isEmpty
        ? 'Your appointment'
        : booking.title;
    final details = [
      booking.bookingDate,
      booking.time,
    ].where((value) => value.trim().isNotEmpty).join(' at ');
    if (details.isEmpty) {
      return '$serviceName has been added to your appointments.';
    }
    return '$serviceName is booked for $details.';
  }

  static String _buildStatusMessage(Booking booking) {
    final serviceName = booking.title.isEmpty
        ? 'Your appointment'
        : booking.title;
    return '$serviceName is now ${booking.status.toLowerCase()}.';
  }

  static String _buildScheduleMessage(Booking booking) {
    final serviceName = booking.title.isEmpty
        ? 'Your appointment'
        : booking.title;
    final details = [
      booking.bookingDate,
      booking.time,
    ].where((value) => value.trim().isNotEmpty).join(' at ');
    if (details.isEmpty) {
      return '$serviceName has new appointment details.';
    }
    return '$serviceName was updated to $details.';
  }

  static String _buildConfirmedMessage(Booking booking) {
    final serviceName = booking.title.isEmpty
        ? 'Your appointment'
        : booking.title;
    final details = [
      booking.bookingDate,
      booking.time,
    ].where((value) => value.trim().isNotEmpty).join(' at ');

    if (details.isEmpty) {
      return '$serviceName has been confirmed.';
    }
    return '$serviceName is confirmed for $details.';
  }

  static String _buildWaitingListMessage(Booking booking) {
    final serviceName = booking.title.isEmpty
        ? 'Your appointment'
        : booking.title;
    return '$serviceName request is on the waiting list. We will update you soon.';
  }

  static Future<void> _onBackgroundFetch(String taskId) async {
    await syncBookings(fromBackground: true);
    BackgroundFetch.finish(taskId);
  }

  static void _onBackgroundFetchTimeout(String taskId) {
    BackgroundFetch.finish(taskId);
  }
}

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessEvent task) async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskId = task.taskId;

  if (task.timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  await AppointmentsSyncService.initialize();
  await AppointmentsSyncService.syncBookings(fromBackground: true);
  BackgroundFetch.finish(taskId);
}
