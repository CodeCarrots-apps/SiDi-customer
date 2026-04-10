import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:sidi/utils/app_constants.dart';

class LoginController extends GetxController {
  LoginController({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  String email = '';
  String password = '';
  final String baseUrl = AppConstants.loginUrl;

  bool isLoading = false;
  String? errorMessage;

  Future<LoginResult> login() async {
    isLoading = true;
    errorMessage = null;
    update();
    debugPrint(
      '[LoginController] Login started for ${email.trim().isEmpty ? '<empty>' : email.trim()}',
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        baseUrl,
        data: <String, dynamic>{'email': email.trim(), 'password': password},
        options: Options(
          headers: <String, dynamic>{'Content-Type': 'application/json'},
        ),
      );
      debugPrint(
        '[LoginController] Response received with status ${response.statusCode}',
      );

      final data = response.data ?? <String, dynamic>{};
      final user = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : <String, dynamic>{};

      final result = LoginResult(
        isSuccess: data['success'] == true,
        message: (data['message'] as String?) ?? 'Login completed.',
        token: (data['token'] as String?) ?? '',
        username: (user['username'] as String?) ?? '',
      );

      if (!result.isSuccess) {
        errorMessage = result.message;
        debugPrint(
          '[LoginController] Login rejected by API: ${result.message}',
        );
      } else {
        debugPrint(
          '[LoginController] Login successful: user=${result.username}, email=${email.trim()}',
        );
      }

      return result;
    } on DioException catch (error) {
      debugPrint(
        '[LoginController] DioException during login. status=${error.response?.statusCode}, message=${error.message}',
      );
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        errorMessage =
            (responseData['message'] as String?) ??
            'Login failed. Please try again.';
      } else {
        errorMessage = 'Login failed. Please try again.';
      }

      return LoginResult(
        isSuccess: false,
        message: errorMessage!,
        token: '',
        username: '',
      );
    } catch (error) {
      debugPrint('[LoginController] Unexpected error during login: $error');
      errorMessage = 'Something went wrong. Please try again.';
      return LoginResult(
        isSuccess: false,
        message: errorMessage!,
        token: '',
        username: '',
      );
    } finally {
      isLoading = false;
      update();
    }
  }
}

class LoginResult {
  const LoginResult({
    required this.isSuccess,
    required this.message,
    required this.token,
    required this.username,
  });

  final bool isSuccess;
  final String message;
  final String token;
  final String username;
}
