import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sidi/utils/token_storage.dart';

class FavoriteServiceApi {
  static const String _favoriteServicesUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/user/favorite-services';
  static const String _allFavoritesUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/user/favorites/all';

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
        validateStatus: (status) {
          // Don't throw for any status code; let us handle it
          return true;
        },
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> getFavoriteServices() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint(
        '[FavoriteServiceApi] Token missing when fetching favorite services.',
      );
      return [];
    }
    final dio = _createDio(token);
    try {
      debugPrint('[FavoriteServiceApi] GET: $_favoriteServicesUrl');
      final response = await dio.get(_favoriteServicesUrl);
      debugPrint(
        '[FavoriteServiceApi] Response: ${response.statusCode} - ${response.data}',
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['favorites'] is List) {
          return List<Map<String, dynamic>>.from(data['favorites']);
        }
      }
      return [];
    } catch (error) {
      debugPrint('[FavoriteServiceApi] Error: $error');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addFavoriteService(
    String serviceId,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint(
        '[FavoriteServiceApi] Token missing when adding favorite service.',
      );
      return {'success': false, 'message': 'Authentication token is missing.'};
    }
    final dio = _createDio(token);
    try {
      debugPrint(
        '[FavoriteServiceApi] POST: $_favoriteServicesUrl with serviceId=$serviceId',
      );
      final response = await dio.post(
        _favoriteServicesUrl,
        data: {'serviceId': serviceId},
      );
      debugPrint(
        '[FavoriteServiceApi] Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data;
        }
      }

      // Handle error responses
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      return {
        'success': false,
        'message':
            'Failed to add to favorites. (Status: ${response.statusCode})',
      };
    } catch (error) {
      debugPrint('[FavoriteServiceApi] Error: $error');
      return {'success': false, 'message': error.toString()};
    }
  }

  static Future<Map<String, dynamic>> removeFavoriteService(
    String serviceId,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint(
        '[FavoriteServiceApi] Token missing when removing favorite service.',
      );
      return {'success': false, 'message': 'Authentication token is missing.'};
    }
    final dio = _createDio(token);
    try {
      // Try DELETE with serviceId in path
      debugPrint(
        '[FavoriteServiceApi] DELETE: $_favoriteServicesUrl/$serviceId',
      );
      var response = await dio.delete('$_favoriteServicesUrl/$serviceId');
      debugPrint(
        '[FavoriteServiceApi] Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data;
        }
      }

      // Fallback: try POST with remove action if DELETE fails
      if (response.statusCode == 404 || response.statusCode == 405) {
        debugPrint(
          '[FavoriteServiceApi] DELETE failed with ${response.statusCode}, trying POST with remove action...',
        );
        debugPrint(
          '[FavoriteServiceApi] POST: $_favoriteServicesUrl/remove with serviceId=$serviceId',
        );
        final fallbackResponse = await dio.post(
          '$_favoriteServicesUrl/remove',
          data: {'serviceId': serviceId},
        );
        debugPrint(
          '[FavoriteServiceApi] Fallback Response: ${fallbackResponse.statusCode} - ${fallbackResponse.data}',
        );
        if (fallbackResponse.statusCode == 200 &&
            fallbackResponse.data is Map<String, dynamic>) {
          return fallbackResponse.data as Map<String, dynamic>;
        }
      }

      // Handle error responses
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      return {
        'success': false,
        'message':
            'Failed to remove from favorites. (Status: ${response.statusCode})',
      };
    } catch (error) {
      debugPrint('[FavoriteServiceApi] Error: $error');
      return {'success': false, 'message': error.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllFavorites() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint(
        '[FavoriteServiceApi] Token missing when fetching all favorites.',
      );
      return {'success': false, 'message': 'Authentication token is missing.'};
    }
    final dio = _createDio(token);
    try {
      final response = await dio.get(_allFavoritesUrl);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Failed to fetch favorites.'};
    } catch (error) {
      debugPrint('[FavoriteServiceApi] Error: $error');
      return {'success': false, 'message': error.toString()};
    }
  }
}
