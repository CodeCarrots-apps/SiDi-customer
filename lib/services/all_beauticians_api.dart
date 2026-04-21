import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AllBeauticiansApi {
  static const String _baseUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/beautician/all';

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{'Content-Type': 'application/json'},
      ),
    );
  }

  /// Get all beauticians with optional filters and pagination
  ///
  /// Parameters:
  /// - [page]: Page number for pagination (optional)
  /// - [limit]: Number of records per page (optional)
  /// - [search]: Search term to filter beauticians (optional)
  /// - [status]: Filter by status (e.g., 'Active') (optional)
  ///
  /// Returns a map containing beauticians list and pagination info
  static Future<Map<String, dynamic>> getAllBeauticians({
    int? page,
    int? limit,
    String? search,
    String? status,
  }) async {
    final dio = _createDio();
    try {
      final queryParams = <String, dynamic>{};

      if (page != null) {
        queryParams['page'] = page;
      }

      if (limit != null) {
        queryParams['limit'] = limit;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      debugPrint('[AllBeauticiansApi] GET: $_baseUrl');
      debugPrint('[AllBeauticiansApi] Query params: $queryParams');

      final response = await dio.get(
        _baseUrl,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      debugPrint(
        '[AllBeauticiansApi] Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data;
        }
      }
      return {'success': false, 'beauticians': []};
    } on DioException catch (error) {
      debugPrint(
        '[AllBeauticiansApi] DioException: status=${error.response?.statusCode}, message=${error.message}',
      );
      debugPrint('[AllBeauticiansApi] Response body: ${error.response?.data}');
      return {'success': false, 'beauticians': []};
    } catch (error) {
      debugPrint('[AllBeauticiansApi] Error: $error');
      return {'success': false, 'beauticians': []};
    }
  }
}
