import 'package:dio/dio.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:sidi/utils/app_constants.dart';

class RegisterController extends GetxController {
  RegisterController({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final String baseUrl = AppConstants.registerUrl;

  String name = '';
  String email = '';
  String phone = '';
  String password = '';
  String confirmPassword = '';

  bool isLoading = false;
  String? errorMessage;

  Future<RegisterResult> register() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        baseUrl,
        data: <String, dynamic>{
          'name': name.trim(),
          if (email.trim().isNotEmpty) 'email': email.trim(),
          if (phone.trim().isNotEmpty) 'phone': phone.trim(),
          'password': password,
          if (confirmPassword.trim().isNotEmpty)
            'confirmPassword': confirmPassword,
        },
        options: Options(
          headers: <String, dynamic>{'Content-Type': 'application/json'},
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      final result = RegisterResult(
        isSuccess: data['success'] == true,
        message:
            (data['message'] as String?) ??
            'Registration submitted successfully.',
      );

      if (!result.isSuccess) {
        errorMessage = result.message;
      }

      return result;
    } on DioException catch (error) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        errorMessage =
            (responseData['message'] as String?) ??
            'Registration failed. Please try again.';
      } else {
        errorMessage = 'Registration failed. Please try again.';
      }

      return RegisterResult(isSuccess: false, message: errorMessage!);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      return RegisterResult(isSuccess: false, message: errorMessage!);
    } finally {
      isLoading = false;
      update();
    }
  }
}

class RegisterResult {
  const RegisterResult({required this.isSuccess, required this.message});

  final bool isSuccess;
  final String message;
}
