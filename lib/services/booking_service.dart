import 'dart:convert';

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

  static void _logCreateBookingResponseModel(BookingCreateResponse result) {
    final payload = {
      'success': result.success,
      'message': result.message,
      'booking': result.booking?.toJson(),
      'estimatedPrice': result.estimatedPrice,
      'addonsAmount': result.addonsAmount,
      'travelFee': result.travelFee,
      'assignedBeautician': result.assignedBeautician,
      'broadcastedCount': result.broadcastedCount,
    };

    debugPrint('CREATE BOOKING RESPONSE MODEL: ${jsonEncode(payload)}');
  }

  static String _extractMessageFromData(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final raw = data['message'];
      if (raw is String && raw.trim().isNotEmpty) {
        return raw;
      }
      return fallback;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final raw = map['message'];
      if (raw is String && raw.trim().isNotEmpty) {
        return raw;
      }
      return fallback;
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return fallback;
  }

  static GenericBookingActionResponse _parseGenericActionResponse(
    dynamic data, {
    required String fallbackMessage,
  }) {
    if (data is Map<String, dynamic>) {
      return GenericBookingActionResponse.fromJson(data);
    }

    if (data is Map) {
      return GenericBookingActionResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    return GenericBookingActionResponse(
      success: false,
      message: fallbackMessage,
    );
  }

  /// ---------------------------
  /// CREATE BOOKING
  /// ---------------------------
  static Future<BookingCreateResponse> createBooking({
    required List<String> serviceIds,
    String? beauticianId,
    required String bookingDate,
    required String bookingTime,
    required String locationType,
    required BookingAddress address,
    String? notes,
    String? preferredGender,
    List<String>? addonIds,
  }) async {
    final sanitizedServiceIds = serviceIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    if (sanitizedServiceIds.isEmpty) {
      return BookingCreateResponse(
        success: false,
        message: 'Please select a service before booking.',
      );
    }

    final primaryServiceId = sanitizedServiceIds.first;
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return BookingCreateResponse(
        success: false,
        message: 'Authentication token is missing.',
      );
    }

    final dio = _dio(token);

    final payload = {
      "serviceId": primaryServiceId,
      "serviceIds": sanitizedServiceIds,
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
        final result = BookingCreateResponse.fromJson(response.data);
        _logCreateBookingResponseModel(result);
        return result;
      }

      return BookingCreateResponse(
        success: false,
        message: 'Invalid server response',
      );
    } on DioException catch (e) {
      debugPrint("CREATE BOOKING ERROR: ${e.response?.data}");

      if (e.response?.data is Map<String, dynamic>) {
        final result = BookingCreateResponse.fromJson(e.response!.data);
        _logCreateBookingResponseModel(result);
        return result;
      }

      return BookingCreateResponse(
        success: false,
        message: e.message ?? 'Failed to create booking',
      );
    } catch (e) {
      debugPrint("CREATE BOOKING UNEXPECTED ERROR: $e");
      return BookingCreateResponse(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
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
          if (status != null) "status": status,
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

      if (response.data is Map<String, dynamic>) {
        return BookingDetailResponse.fromJson(response.data);
      }

      if (response.data is Map) {
        return BookingDetailResponse.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      return BookingDetailResponse(
        success: false,
        message: 'Invalid server response',
      );
    } on DioException catch (e) {
      return BookingDetailResponse(
        success: false,
        message: _extractMessageFromData(
          e.response?.data,
          e.message ?? 'Failed to load booking',
        ),
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

      return _parseGenericActionResponse(
        response.data,
        fallbackMessage: 'Invalid server response',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return _parseGenericActionResponse(
          e.response!.data,
          fallbackMessage: _extractMessageFromData(
            e.response?.data,
            e.message ?? 'Cancel failed',
          ),
        );
      }

      return GenericBookingActionResponse(
        success: false,
        message: e.message ?? 'Cancel failed',
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

      return _parseGenericActionResponse(
        response.data,
        fallbackMessage: 'Invalid server response',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return _parseGenericActionResponse(
          e.response!.data,
          fallbackMessage: _extractMessageFromData(
            e.response?.data,
            e.message ?? 'Reschedule failed',
          ),
        );
      }

      return GenericBookingActionResponse(
        success: false,
        message: e.message ?? 'Reschedule failed',
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
