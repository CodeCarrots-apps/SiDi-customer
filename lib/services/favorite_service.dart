import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sidi/utils/token_storage.dart';

class FavoriteService {
  static const String _favoritesUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/user/favorites';

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

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[FavoriteService] Token missing when fetching favorites.');
      return [];
    }
    final dio = _createDio(token);
    debugPrint('[FavoriteService] Sending GET to $_favoritesUrl');
    try {
      final response = await dio.get(_favoritesUrl);
      debugPrint(
        '[FavoriteService] Response: status=${response.statusCode}, data=${response.data}',
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['favorites'] is List) {
          return List<Map<String, dynamic>>.from(data['favorites']);
        }
      }
      return [];
    } on DioException catch (error) {
      debugPrint(
        '[FavoriteService] DioException: status=${error.response?.statusCode}, data=${error.response?.data}, message=${error.message}',
      );
      return [];
    } catch (error) {
      debugPrint('[FavoriteService] Error: $error');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addToFavorites(
    String beauticianId,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[FavoriteService] Token missing when adding to favorites.');
      return {'success': false, 'message': 'Authentication token is missing.'};
    }
    final dio = _createDio(token);
    debugPrint(
      '[FavoriteService] Sending POST to $_favoritesUrl with beauticianId: $beauticianId',
    );
    try {
      final response = await dio.post(
        _favoritesUrl,
        data: {'beauticianId': beauticianId},
      );
      debugPrint(
        '[FavoriteService] Response: status=${response.statusCode}, data=${response.data}',
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Failed to add to favorites.'};
    } on DioException catch (error) {
      debugPrint(
        '[FavoriteService] DioException: status=${error.response?.statusCode}, data=${error.response?.data}, message=${error.message}',
      );
      return {
        'success': false,
        'message': error.response?.data['message'] ?? error.message,
      };
    } catch (error) {
      debugPrint('[FavoriteService] Error: $error');
      return {'success': false, 'message': error.toString()};
    }
  }

  static Future<Map<String, dynamic>> removeFromFavorites(
    String beauticianId,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint(
        '[FavoriteService] Token missing when removing from favorites.',
      );
      return {'success': false, 'message': 'Authentication token is missing.'};
    }
    final dio = _createDio(token);
    debugPrint(
      '[FavoriteService] Sending DELETE to $_favoritesUrl/$beauticianId',
    );
    try {
      final response = await dio.delete('$_favoritesUrl/$beauticianId');
      debugPrint(
        '[FavoriteService] Response: status=${response.statusCode}, data=${response.data}',
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Failed to remove from favorites.'};
    } on DioException catch (error) {
      debugPrint(
        '[FavoriteService] DioException: status=${error.response?.statusCode}, data=${error.response?.data}, message=${error.message}',
      );
      return {
        'success': false,
        'message': error.response?.data['message'] ?? error.message,
      };
    } catch (error) {
      debugPrint('[FavoriteService] Error: $error');
      return {'success': false, 'message': error.toString()};
    }
  }
}
