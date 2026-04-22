import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sidi/utils/token_storage.dart';

class FavoriteService {
  static const String _baseUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/user/favorites';

  static final Dio _dio =
      Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await TokenStorage.getToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              debugPrint('[API] ${options.method} ${options.path}');
              return handler.next(options);
            },
            onResponse: (response, handler) {
              debugPrint(
                '[API RESPONSE] ${response.statusCode} => ${response.data}',
              );
              return handler.next(response);
            },
            onError: (DioException e, handler) {
              debugPrint('[API ERROR] ${e.message}');
              return handler.next(e);
            },
          ),
        );

  // ------------------------
  // Common Response Handler
  // ------------------------
  static List<Map<String, dynamic>> _parseListResponse(Response response) {
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['favorites'] is List) {
        return List<Map<String, dynamic>>.from(data['favorites']);
      }
    }
    return [];
  }

  static Map<String, dynamic> _parseMapResponse(Response response) {
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'success': false, 'message': 'Invalid server response'};
  }

  static Map<String, dynamic> _handleError(DioException error) {
    String message = 'Something went wrong';

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timeout. Please try again.';
    } else if (error.type == DioExceptionType.badResponse) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        message = data['message'];
      } else {
        message = 'Server error (${error.response?.statusCode})';
      }
    } else if (error.type == DioExceptionType.unknown) {
      message = 'No internet connection';
    }

    return {'success': false, 'message': message};
  }

  // ------------------------
  // API METHODS
  // ------------------------

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final response = await _dio.get(_baseUrl);
      return _parseListResponse(response);
    } on DioException catch (e) {
      debugPrint('[getFavorites] ${_handleError(e)}');
      return [];
    }
  }

  static Future<bool> isFavorite(String beauticianId) async {
    try {
      final response = await _dio.get('$_baseUrl/$beauticianId');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['favorites'] is List) {
          final List favorites = data['favorites'];
          return favorites.isNotEmpty; // ✅ CORRECT LOGIC
        }
      }

      return false;
    } catch (e) {
      debugPrint('[isFavorite] Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> addToFavorites(
    String beauticianId,
  ) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {'beauticianId': beauticianId},
      );
      return _parseMapResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> removeFromFavorites(
    String beauticianId,
  ) async {
    try {
      final response = await _dio.delete(
        _baseUrl,
        data: {'beauticianId': beauticianId}, // ✅ IMPORTANT FIX
      );

      return _parseMapResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
}
