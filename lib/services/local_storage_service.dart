import 'package:shared_preferences/shared_preferences.dart';

import '../models/address_model.dart';
import '../models/app_notification.dart';
import '../models/booking.dart';
import '../models/payment_method_model.dart';

class LocalStorageService {
  static const _addressesKey = 'saved_addresses';
  static const _paymentMethodsKey = 'saved_payment_methods';
  static const _bookingsKey = 'cached_bookings';
  static const _appNotificationsKey = 'app_notifications';
  static const _bookingSyncSeededKey = 'booking_sync_seeded';

  static Future<List<AddressModel>> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_addressesKey);
    if (saved == null || saved.isEmpty) {
      return [];
    }
    return AddressModel.listFromJson(saved);
  }

  static Future<void> saveAddresses(List<AddressModel> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressesKey, AddressModel.listToJson(addresses));
  }

  static Future<List<PaymentMethodModel>> loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_paymentMethodsKey);
    if (saved == null || saved.isEmpty) {
      return [];
    }
    return PaymentMethodModel.listFromJson(saved);
  }

  static Future<void> savePaymentMethods(
    List<PaymentMethodModel> paymentMethods,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _paymentMethodsKey,
      PaymentMethodModel.listToJson(paymentMethods),
    );
  }

  static Future<List<Booking>> loadCachedBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_bookingsKey);
    if (saved == null || saved.isEmpty) {
      return [];
    }
    return Booking.listFromJson(saved);
  }

  static Future<void> saveCachedBookings(List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookingsKey, Booking.listToJson(bookings));
  }

  static Future<void> addCachedBooking(Booking booking) async {
    final bookings = await loadCachedBookings();
    if (bookings.any((item) => item.id == booking.id)) {
      return;
    }
    bookings.insert(0, booking);
    await saveCachedBookings(bookings);
  }

  static Future<void> clearCachedBookings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookingsKey);
  }

  static Future<List<AppNotification>> loadAppNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_appNotificationsKey);
    if (saved == null || saved.isEmpty) {
      return [];
    }
    return AppNotification.listFromJson(saved);
  }

  static Future<void> saveAppNotifications(
    List<AppNotification> notifications,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _appNotificationsKey,
      AppNotification.listToJson(notifications),
    );
  }

  static Future<void> clearAppNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appNotificationsKey);
  }

  static Future<bool> hasSeededBookingSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bookingSyncSeededKey) ?? false;
  }

  static Future<void> setBookingSyncSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bookingSyncSeededKey, true);
  }
}
