import 'package:dio/dio.dart';
import 'package:sidi/utils/token_storage.dart';

class RatingController {
  static const String _serviceUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/reviews/service';
  static const String _curatedServiceUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/reviews/curated-service';

  /// Submit rating for a regular service
  static Future<Response?> submitServiceRating({
    required String serviceId,
    required int rating,
    String? reasons,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) return null;
    final dio = Dio();
    try {
      final response = await dio.post(
        _serviceUrl,
        data: {
          'serviceId': serviceId,
          'rating': rating,
          if (reasons != null) 'reasons': reasons,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      print(
        'Failed to submit service rating: '
        'serviceId=$serviceId, rating=$rating, reasons=$reasons, error=$e',
      );
      return null;
    }
  }

  /// Submit rating for a curated service
  static Future<Response?> submitCuratedServiceRating({
    required String curatedServiceId,
    required int rating,
    String? reasons,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) return null;
    final dio = Dio();
    try {
      final response = await dio.post(
        _curatedServiceUrl,
        data: {
          'curatedServiceId': curatedServiceId,
          'rating': rating,
          if (reasons != null) 'reasons': reasons,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      print(
        'Failed to submit curated service rating: '
        'curatedServiceId=$curatedServiceId, rating=$rating, reasons=$reasons, error=$e',
      );
      return null;
    }
  }
}
