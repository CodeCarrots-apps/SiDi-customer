import 'package:dio/dio.dart';
import 'package:sidi/utils/token_storage.dart';
import '../models/booking.dart';

class BookingService {
  static const String _bookingHistoryUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/user/booking-history';

  static Future<List<Booking>> fetchBookings() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    final dio = Dio(
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

    final response = await dio.get(_bookingHistoryUrl);
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['bookings'] is List) {
        return (data['bookings'] as List)
            .map((e) => Booking.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }
}
