import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/presentation/loginscreen.dart';
import 'package:sidi/utils/app_constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.userId,
    required this.resetToken,
  });

  final String userId;
  final String resetToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter a new password');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    debugPrint('[ResetPassword] Calling reset-password');
    debugPrint('[ResetPassword] URL: ${AppConstants.resetpass}');
    debugPrint('[ResetPassword] Body: {userId: ${widget.userId}, resetToken: ${widget.resetToken}, newPassword: ***, confirmPassword: ***}');

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConstants.resetpass,
        data: {
          'userId': widget.userId,
          'resetToken': widget.resetToken,
          'newPassword': password,
          'confirmPassword': confirmPassword,
        },
      );

      final data = response.data ?? {};
      debugPrint('[ResetPassword] Response status: ${response.statusCode}');
      debugPrint('[ResetPassword] Response body: $data');

      if (data['success'] == true) {
        if (!mounted) return;
        debugPrint('[ResetPassword] Password reset successful, navigating to login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] as String? ?? 'Password reset successfully'),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => true,
        );
      } else {
        debugPrint('[ResetPassword] API returned success=false');
        setState(() {
          _errorMessage = data['message'] as String? ?? 'Password reset failed';
        });
      }
    } on DioException catch (e) {
      debugPrint('[ResetPassword] DioException: ${e.message}');
      debugPrint('[ResetPassword] Response status: ${e.response?.statusCode}');
      debugPrint('[ResetPassword] Response data: ${e.response?.data}');
      String msg = 'Password reset failed';
      if (e.response?.data is Map) {
        msg = (e.response!.data as Map)['message'] as String? ?? msg;
      } else if (e.message != null) {
        msg = e.message!;
      }
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kIvoryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, size: 18),
              ),
              const SizedBox(height: 20),
              Text(
                'Reset Password',
                style: kHeaderStyle,
              ),
              const SizedBox(height: 12),
              Text(
                'Choose a new password for your account.',
                style: kSubHeaderStyle.copyWith(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 40),
              Text(
                'NEW PASSWORD',
                style: kLabelTextStyle,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter new password',
                  hintStyle: kInputHintStyle,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kWarmGrey200),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kEspressoColor),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: kWarmGrey600,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'CONFIRM PASSWORD',
                style: kLabelTextStyle,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  hintStyle: kInputHintStyle,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kWarmGrey200),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kEspressoColor),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: kWarmGrey600,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: kInputFieldHeight,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kEspressoColor,
                    foregroundColor: kIvoryColor,
                    shape: RoundedRectangleBorder(borderRadius: kFullBorderRadius),
                    textStyle: kButtonTextStyle,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('RESET PASSWORD'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
