import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// import 'package:sidi/models/booking.dart';
import 'package:sidi/models/booking_models.dart';
// import 'package:sidi/services/local_storage_service.dart';
import 'package:sidi/utils/token_storage.dart';

class BookingService {
  static const String _baseUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/bookings';

  static Dio _dio(String token) {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  /// ---------------------------
  /// CREATE BOOKING
  /// ---------------------------
  static Future<BookingCreateResponse> createBooking({
    required String serviceId,
    String? beauticianId,
    required String bookingDate,
    required String bookingTime,
    required String locationType,
    required BookingAddress address,
    String? notes,
    String? preferredGender,
    List<String>? addonIds,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return BookingCreateResponse(
        success: false,
        message: 'Authentication token is missing.',
      );
    }

    final dio = _dio(token);

    final payload = {
      "serviceId": serviceId,
      "beauticianId": beauticianId,
      "bookingDate": bookingDate,
      "bookingTime": bookingTime,
      "locationType": locationType,
      "address": address.toJson(),
      "notes": notes,
      "preferredGender": preferredGender,
      "addonIds": addonIds,
    }..removeWhere((key, value) => value == null);

    try {
      final response = await dio.post('/create', data: payload);

      if (response.data is Map<String, dynamic>) {
        return BookingCreateResponse.fromJson(response.data);
      }

      return BookingCreateResponse(
        success: false,
        message: 'Invalid server response',
      );
    } on DioException catch (e) {
      debugPrint("CREATE BOOKING ERROR: ${e.response?.data}");

      if (e.response?.data is Map<String, dynamic>) {
        return BookingCreateResponse.fromJson(e.response!.data);
      }

      return BookingCreateResponse(
        success: false,
        message: e.message ?? 'Failed to create booking',
      );
    }
  }

  /// ---------------------------
  /// MY BOOKINGS
  /// ---------------------------
  static Future<MyBookingsResponse> getMyBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return MyBookingsResponse(
        success: false,
        message: 'Authentication token is missing.',
        bookings: [],
        total: 0,
        currentPage: page,
      );
    }

    final dio = _dio(token);

    try {
      final response = await dio.get(
        '/my-bookings',
        queryParameters: {
          "page": page,
          "limit": limit,
          "status": ?status,
        },
      );

      final result = MyBookingsResponse.fromJson(response.data);

      // No local caching

      return result;
    } catch (e) {
      return MyBookingsResponse(
        success: false,
        message: 'Network error - unable to load bookings',
        bookings: [],
        total: 0,
        currentPage: page,
      );
    }
  }

  /// ---------------------------
  /// BOOKING DETAILS
  /// ---------------------------
  static Future<BookingDetailResponse> getBookingDetails(
    String bookingId,
  ) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return BookingDetailResponse(
        success: false,
        message: 'Authentication required',
      );
    }

    final dio = _dio(token);

    try {
      final response = await dio.get('/$bookingId');

      return BookingDetailResponse.fromJson(response.data);
    } on DioException catch (e) {
      return BookingDetailResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            e.message ??
            'Failed to load booking',
      );
    }
  }

  /// ---------------------------
  /// CANCEL BOOKING
  /// ---------------------------
  static Future<GenericBookingActionResponse> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return GenericBookingActionResponse(
        success: false,
        message: 'Authentication required',
      );
    }

    final dio = _dio(token);

    try {
      final response = await dio.put(
        '/$bookingId/cancel',
        data: {"reason": reason},
      );

      return GenericBookingActionResponse.fromJson(response.data);
    } on DioException catch (e) {
      return GenericBookingActionResponse(
        success: false,
        message: e.response?.data?['message'] ?? e.message ?? 'Cancel failed',
      );
    }
  }

  /// ---------------------------
  /// RESCHEDULE BOOKING
  /// ---------------------------
  static Future<GenericBookingActionResponse> rescheduleBooking({
    required String bookingId,
    required String newDate,
    required String newTime,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return GenericBookingActionResponse(
        success: false,
        message: 'Authentication required',
      );
    }

    final dio = _dio(token);

    try {
      final response = await dio.put(
        '/$bookingId/reschedule',
        data: {"newDate": newDate, "newTime": newTime},
      );

      return GenericBookingActionResponse.fromJson(response.data);
    } on DioException catch (e) {
      return GenericBookingActionResponse(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'Reschedule failed',
      );
    }
  }

  /// ---------------------------
  /// COMPLETE BOOKING
  /// ---------------------------
  static Future<GenericBookingActionResponse> completeBooking(
    String bookingId,
  ) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return GenericBookingActionResponse(
        success: false,
        message: 'Authentication required',
      );
    }

    final dio = _dio(token);

    try {
      final response = await dio.post('/$bookingId/complete');

      return GenericBookingActionResponse.fromJson(response.data);
    } on DioException catch (e) {
      return GenericBookingActionResponse(
        success: false,
        message: e.response?.data?['message'] ?? e.message ?? 'Complete failed',
      );
    }
  }
}
