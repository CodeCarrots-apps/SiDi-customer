import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sidi/models/booking.dart';
import 'package:sidi/models/booking_models.dart';
import 'package:sidi/utils/token_storage.dart';

class BookingService {
  static const String _baseUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/bookings';
  static const String _myBookingsUrl = '$_baseUrl/my-bookings';
  static const String _availableSlotsUrl = '$_baseUrl/available-slots';

  static Dio _createDio(String token) {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  static Future<List<Booking>> fetchBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await fetchBookingsResponse(
      page: page,
      limit: limit,
      status: status,
    );
    return response.bookings;
  }

  static Future<MyBookingsResponse> fetchBookingsResponse({
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

    final dio = _createDio(token);
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    final response = await dio.get(
      _myBookingsUrl,
      queryParameters: queryParameters,
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return MyBookingsResponse.fromJson(response.data as Map<String, dynamic>);
    }

    return MyBookingsResponse(
      success: false,
      message: 'Failed to fetch bookings.',
      bookings: [],
      total: 0,
      currentPage: page,
    );
  }

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

    final dio = _createDio(token);
    final payload = <String, dynamic>{
      'serviceId': serviceId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'locationType': locationType,
      'address': address.toJson(),
    };

    if (beauticianId != null && beauticianId.isNotEmpty) {
      payload['beauticianId'] = beauticianId;
    }
    if (notes != null && notes.isNotEmpty) {
      payload['notes'] = notes;
    }
    if (preferredGender != null && preferredGender.isNotEmpty) {
      payload['preferredGender'] = preferredGender;
    }
    if (addonIds != null && addonIds.isNotEmpty) {
      payload['addonIds'] = addonIds;
    }

    debugPrint('BookingService.createBooking payload: $payload');

    try {
      final response = await dio.post('$_baseUrl/create', data: payload);
      debugPrint(
        'BookingService.createBooking response: status=${response.statusCode}, data=${response.data}',
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return BookingCreateResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      if (response.data is Map<String, dynamic>) {
        return BookingCreateResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } on DioException catch (error) {
      debugPrint(
        'BookingService.createBooking DioException: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}, '
        'message=${error.message}',
      );
      if (error.response?.data is Map<String, dynamic>) {
        return BookingCreateResponse.fromJson(
          error.response!.data as Map<String, dynamic>,
        );
      }

      return BookingCreateResponse(
        success: false,
        message: error.message ?? 'Failed to create booking.',
      );
    }

    return BookingCreateResponse(
      success: false,
      message: 'Failed to create booking.',
    );
  }

  static Future<BookingDetailResponse> getBookingDetails(
    String bookingId,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return BookingDetailResponse(
        success: false,
        message: 'Authentication token is missing.',
      );
    }

    final dio = _createDio(token);
    final response = await dio.get('$_baseUrl/$bookingId');
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return BookingDetailResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return BookingDetailResponse(
      success: false,
      message: 'Failed to load booking details.',
    );
  }

  static Future<GenericBookingActionResponse> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return GenericBookingActionResponse(
        success: false,
        message: 'Authentication token is missing.',
      );
    }

    final dio = _createDio(token);
    final response = await dio.put(
      '$_baseUrl/$bookingId/cancel',
      data: {'reason': reason},
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return GenericBookingActionResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return GenericBookingActionResponse(
      success: false,
      message: 'Failed to cancel booking.',
    );
  }

  static Future<GenericBookingActionResponse> rescheduleBooking(
    String bookingId,
    String newDate,
    String newTime,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return GenericBookingActionResponse(
        success: false,
        message: 'Authentication token is missing.',
      );
    }

    final dio = _createDio(token);
    final response = await dio.put(
      '$_baseUrl/$bookingId/reschedule',
      data: {'newDate': newDate, 'newTime': newTime},
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return GenericBookingActionResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return GenericBookingActionResponse(
      success: false,
      message: 'Failed to reschedule booking.',
    );
  }

  static Future<AvailableSlotsResponse> getAvailableSlots({
    required String serviceId,
    required String date,
    String? beauticianId,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{'Content-Type': 'application/json'},
      ),
    );

    final queryParameters = <String, dynamic>{
      'serviceId': serviceId,
      'date': date,
    };
    if (beauticianId != null && beauticianId.isNotEmpty) {
      queryParameters['beauticianId'] = beauticianId;
    }

    final response = await dio.get(
      _availableSlotsUrl,
      queryParameters: queryParameters,
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return AvailableSlotsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return AvailableSlotsResponse(
      success: false,
      message: 'Failed to load available slots.',
      availableSlots: [],
    );
  }

  static Future<GenericBookingActionResponse> completeBooking(
    String bookingId,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return GenericBookingActionResponse(
        success: false,
        message: 'Authentication token is missing.',
      );
    }

    final dio = _createDio(token);
    final response = await dio.post('$_baseUrl/$bookingId/complete');
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return GenericBookingActionResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return GenericBookingActionResponse(
      success: false,
      message: 'Failed to complete booking.',
    );
  }
}
