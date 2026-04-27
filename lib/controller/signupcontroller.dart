// import 'package:dio/dio.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:sidi/utils/app_constants.dart';

// class RegisterController extends GetxController {
//   RegisterController({Dio? dio}) : _dio = dio ?? Dio();

//   final Dio _dio;
//   final String baseUrl = AppConstants.registerUrl;

//   String name = '';
//   String email = '';
//   String phone = '';
//   String password = '';
//   String confirmPassword = '';

//   bool isLoading = false;
//   String? errorMessage;

//   Future<RegisterResult> register() async {
//     isLoading = true;
//     errorMessage = null;
//     update();

//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         baseUrl,
//         data: <String, dynamic>{
//           'name': name.trim(),
//           if (email.trim().isNotEmpty) 'email': email.trim(),
//           'phone': phone.trim(),
//           'password': password,
//           if (confirmPassword.trim().isNotEmpty)
//             'confirmPassword': confirmPassword,
//         },
//         options: Options(
//           headers: <String, dynamic>{'Content-Type': 'application/json'},
//         ),
//       );

//       final data = response.data ?? <String, dynamic>{};
//       final result = RegisterResult(
//         isSuccess: data['success'] == true,
//         message:
//             (data['message'] as String?) ??
//             'Registration submitted successfully.',
//       );
//       print({
//         'name': name,
//         'email': email,
//         'phone': phone,
//         'password': password,
//         'confirmPassword': confirmPassword,
//       });

//       if (!result.isSuccess) {
//         errorMessage = result.message;
//       }

//       return result;
//     } on DioException catch (error) {
//       final responseData = error.response?.data;
//       if (responseData is Map<String, dynamic>) {
//         errorMessage =
//             (responseData['message'] as String?) ??
//             'Registration failed. Please try again.';
//       } else {
//         errorMessage = 'Registration failed. Please try again.';
//       }

//       return RegisterResult(isSuccess: false, message: errorMessage!);
//     } catch (_) {
//       errorMessage = 'Something went wrong. Please try again.';
//       return RegisterResult(isSuccess: false, message: errorMessage!);
//     } finally {
//       isLoading = false;
//       update();
//     }
//   }
// }

// class RegisterResult {
//   const RegisterResult({required this.isSuccess, required this.message});

//   final bool isSuccess;
//   final String message;
// }

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sidi/utils/app_constants.dart';

class RegisterController extends GetxController {
  RegisterController({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            ),
          );

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
    /// 🔹 Validate inputs first
    final validationError = _validateInputs();
    if (validationError != null) {
      errorMessage = validationError;
      update();
      return RegisterResult(isSuccess: false, message: validationError);
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        baseUrl,
        data: {
          'name': name.trim(),
          if (email.trim().isNotEmpty) 'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
          if (confirmPassword.trim().isNotEmpty)
            'confirmPassword': confirmPassword,
        },
      );

      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final data = response.data ?? {};

        final result = RegisterResult(
          isSuccess: data['success'] == true,
          message: data['message'] ?? 'Registration successful',
        );

        if (!result.isSuccess) {
          errorMessage = result.message;
        }

        return result;
      } else {
        errorMessage = 'Server error ($statusCode)';
        return RegisterResult(isSuccess: false, message: errorMessage!);
      }
    } on DioException catch (e) {
      errorMessage = _handleDioError(e);
      return RegisterResult(isSuccess: false, message: errorMessage!);
    } catch (e) {
      errorMessage = 'Unexpected error occurred';
      return RegisterResult(isSuccess: false, message: errorMessage!);
    } finally {
      isLoading = false;
      update();
    }
  }

  /// 🔹 Input validation
  String? _validateInputs() {
    if (name.trim().isEmpty) return 'Name is required';

    if (phone.trim().isEmpty) return 'Phone is required';

    if (password.isEmpty) return 'Password is required';

    if (password.length < 6) return 'Password must be at least 6 characters';

    if (confirmPassword.isNotEmpty && password != confirmPassword) {
      return 'Passwords do not match';
    }

    if (email.isNotEmpty && !GetUtils.isEmail(email.trim())) {
      return 'Invalid email format';
    }

    return null;
  }

  /// 🔹 Centralized Dio error handling
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond';
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          return data['message'] ?? 'Server error';
        }
        return 'Server error';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error. Please try again.';
    }
  }
}

class RegisterResult {
  const RegisterResult({required this.isSuccess, required this.message});

  final bool isSuccess;
  final String message;
}
