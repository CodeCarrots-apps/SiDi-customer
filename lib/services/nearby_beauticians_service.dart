import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/token_storage.dart';
import '../models/nearby_beauticians_response.dart';

class NearbyBeauticiansService {
  static const String _baseUrl =
      'https://sidi.mobilegear.co.in/api/beauticians';

  static Future<NearbyBeauticiansResponse> getNearbyBeauticians({
    required double latitude,
    required double longitude,
    String? serviceId,
    double? radius,
  }) async {
    final token = await TokenStorage.getToken();
    final dio = Dio(
      BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
    final queryParams = {
      'latitude': latitude,
      'longitude': longitude,
      'serviceId': serviceId,
      'radius': radius,
    };

    debugPrint('[NearbyBeauticiansService] GET: $_baseUrl');
    debugPrint('[NearbyBeauticiansService] Query params: $queryParams');

    try {
      final response = await dio.get(_baseUrl, queryParameters: queryParams);

      debugPrint(
        '[NearbyBeauticiansService] Response: [200m${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return NearbyBeauticiansResponse.fromJson(data);
      }
      return NearbyBeauticiansResponse(
        beauticians: [],
        total: 0,
        page: 1,
        totalPages: 1,
      );
    } on DioException catch (error) {
      debugPrint(
        '[NearbyBeauticiansService] DioException: status=${error.response?.statusCode}, message=${error.message}',
      );
      debugPrint(
        '[NearbyBeauticiansService] Response body: ${error.response?.data}',
      );
      return NearbyBeauticiansResponse(
        beauticians: [],
        total: 0,
        page: 1,
        totalPages: 1,
      );
    } catch (error) {
      debugPrint('[NearbyBeauticiansService] Error: $error');
      return NearbyBeauticiansResponse(
        beauticians: [],
        total: 0,
        page: 1,
        totalPages: 1,
      );
    }
  }
}
