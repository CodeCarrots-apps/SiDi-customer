import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/token_storage.dart';

class NearbyBeauticiansApi {
  static const String _baseUrl =
      'https://sidi.mobilegear.co.in/api/beauticians';

  static Future<Dio> _createDio() async {
    final token = await TokenStorage.getToken();
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  /// Get nearby beauticians based on location and optional filters
  ///
  /// Parameters:
  /// - [latitude]: User's latitude (required)
  /// - [longitude]: User's longitude (required)
  /// - [serviceId]: Optional service ID to filter beauticians by service
  /// - [radius]: Optional search radius in kilometers
  ///
  /// Returns a list of nearby beauticians
  static Future<List<Map<String, dynamic>>> getNearbyBeauticians({
    required double latitude,
    required double longitude,
    String? serviceId,
    double? radius,
  }) async {
    final dio = await _createDio();
    try {
      final queryParams = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
      };

      if (serviceId != null && serviceId.isNotEmpty) {
        queryParams['serviceId'] = serviceId;
      }

      if (radius != null) {
        queryParams['radius'] = radius;
      }

      debugPrint('[NearbyBeauticiansApi] GET: $_baseUrl');
      debugPrint('[NearbyBeauticiansApi] Query params: $queryParams');

      final response = await dio.get(_baseUrl, queryParameters: queryParams);

      debugPrint(
        '[NearbyBeauticiansApi] Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['beauticians'] is List) {
          return List<Map<String, dynamic>>.from(data['beauticians']);
        }
      }
      return [];
    } on DioException catch (error) {
      debugPrint(
        '[NearbyBeauticiansApi] DioException: status=${error.response?.statusCode}, message=${error.message}',
      );
      debugPrint(
        '[NearbyBeauticiansApi] Response body: ${error.response?.data}',
      );
      return [];
    } catch (error) {
      debugPrint('[NearbyBeauticiansApi] Error: $error');
      return [];
    }
  }
}
