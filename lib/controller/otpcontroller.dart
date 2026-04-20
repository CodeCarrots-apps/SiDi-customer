import 'package:dio/dio.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:sidi/utils/app_constants.dart';

class OtpController extends GetxController {
  OtpController({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final String verifyUrl = AppConstants.verifyOtpUrl;
  final String resendUrl = AppConstants.resendOtpUrl;

  String userId = '';
  String otp = '';
  String type = 'email';

  bool isLoading = false;
  String? errorMessage;

  Future<VerifyOtpResult> verifyOtp() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        verifyUrl,
        data: <String, dynamic>{'userId': userId, 'otp': otp, 'type': type},
        options: Options(
          headers: <String, dynamic>{'Content-Type': 'application/json'},
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      final isSuccess = data['success'] == true;
      final message = (data['message'] as String?) ?? 'Verification completed.';
      final token = (data['token'] as String?) ?? '';
      final user = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : <String, dynamic>{};

      if (!isSuccess) {
        errorMessage = message;
      }

      return VerifyOtpResult(
        isSuccess: isSuccess,
        message: message,
        token: token,
        username: (user['username'] as String?) ?? '',
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        errorMessage =
            (responseData['message'] as String?) ??
            'Verification failed. Please try again.';
      } else {
        errorMessage = 'Verification failed. Please try again.';
      }
      return VerifyOtpResult(
        isSuccess: false,
        message: errorMessage!,
        token: '',
        username: '',
      );
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      return VerifyOtpResult(
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

  Future<ActionResult> resendOtp() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        resendUrl,
        data: <String, dynamic>{'userId': userId, 'type': type},
        options: Options(
          headers: <String, dynamic>{'Content-Type': 'application/json'},
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      final isSuccess = data['success'] == true;
      final message =
          (data['message'] as String?) ?? 'OTP resend request completed.';

      if (!isSuccess) {
        errorMessage = message;
      }

      return ActionResult(isSuccess: isSuccess, message: message);
    } on DioException catch (error) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        errorMessage =
            (responseData['message'] as String?) ??
            'Resend OTP failed. Please try again.';
      } else {
        errorMessage = 'Resend OTP failed. Please try again.';
      }
      return ActionResult(isSuccess: false, message: errorMessage!);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      return ActionResult(isSuccess: false, message: errorMessage!);
    } finally {
      isLoading = false;
      update();
    }
  }
}

class VerifyOtpResult {
  const VerifyOtpResult({
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

class ActionResult {
  const ActionResult({required this.isSuccess, required this.message});

  final bool isSuccess;
  final String message;
}
