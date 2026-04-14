import 'package:dio/dio.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sidi/utils/token_storage.dart';

class LogoutController extends GetxController {
  LogoutController({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final String logoutUrl =
      'https://sidi.mobilegear.co.in/api/mobileapp/auth/logout';

  bool isLoading = false;
  String? errorMessage;

  Future<bool> logout(String token) async {
    isLoading = true;
    errorMessage = null;
    update();
    try {
      final response = await _dio.post(
        logoutUrl,
        options: Options(
          headers: <String, dynamic>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        // Clear token from shared_preferences
        await TokenStorage.deleteToken();
        return true;
      } else {
        errorMessage = 'Logout failed. Please try again.';
        return false;
      }
    } on DioException catch (error) {
      errorMessage =
          error.response?.data['message'] ?? 'Logout failed. Please try again.';
      return false;
    } catch (error) {
      errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }
}
