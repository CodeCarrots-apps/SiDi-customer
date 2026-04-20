import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sidi/utils/token_storage.dart';

class LoginController extends GetxController {
  LoginController({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
            ),
          );

  final Dio _dio;
  String identifier = '';
  String password = '';
  final String baseUrl = AppConstants.loginUrl;

  bool isLoading = false;
  String? errorMessage;

  Future<LoginResult> login() async {
    isLoading = true;
    errorMessage = null;
    update();
    final trimmedIdentifier = identifier.trim();
    final isPhoneLogin = RegExp(r'^\+?\d{7,15}$').hasMatch(trimmedIdentifier);
    final isEmailLogin = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(trimmedIdentifier);

    debugPrint(
      '[LoginController] Login started for ${trimmedIdentifier.isEmpty ? '<empty>' : trimmedIdentifier}',
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        baseUrl,
        data: <String, dynamic>{
          if (isPhoneLogin)
            'phone': trimmedIdentifier
          else if (isEmailLogin)
            'email': trimmedIdentifier
          else
            'username': trimmedIdentifier,
          'password': password,
        },
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
      final token = (data['token'] as String?) ?? '';
      final isSuccess = data['success'] == true && token.isNotEmpty;
      final message = (data['message'] as String?) ?? 'Login completed.';
      final result = LoginResult(
        isSuccess: isSuccess,
        message: message,
        token: token,
        username: (user['username'] as String?) ?? '',
      );

      if (!result.isSuccess) {
        errorMessage = result.token.isEmpty && data['success'] == true
            ? 'Login failed. Invalid token received.'
            : result.message;
        debugPrint('[LoginController] Login rejected by API: $errorMessage');
      } else {
        debugPrint(
          '[LoginController] Login successful: user=${result.username}, identifier=$trimmedIdentifier',
        );
        // Save token using shared_preferences
        await TokenStorage.saveToken(result.token);
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
