import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';

class BookingService {
  static const String _baseUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/user/booking-history';

  static Future<List<Booking>> fetchBookings() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['bookings'] is List) {
        return (data['bookings'] as List)
            .map((e) => Booking.fromJson(e))
            .toList();
      }
    }
    return [];
  }
}
