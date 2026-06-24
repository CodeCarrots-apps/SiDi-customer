import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/presentation/resetpasswordscreen.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sms_autofill/sms_autofill.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key, required this.userId});

  final String userId;

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));

  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final SmsAutoFill _smsAutoFill = SmsAutoFill();
  final TextEditingController _hiddenOtpController = TextEditingController();
  final FocusNode _hiddenFocusNode = FocusNode();
  StreamSubscription<String>? _smsSubscription;
  bool _isVerifying = false;
  String? _errorMessage;

  static const int _resendDuration = 30;
  int _resendRemaining = 0;
  Timer? _resendTimer;

  String get _otpCode => _codeControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _listenForSms();
    _hiddenOtpController.addListener(_onHiddenOtpChanged);
    for (final node in _focusNodes) {
      node.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _hiddenOtpController.removeListener(_onHiddenOtpChanged);
    _hiddenOtpController.dispose();
    _hiddenFocusNode.dispose();
    for (final node in _focusNodes) {
      node.removeListener(_onFocusChanged);
    }
    _smsSubscription?.cancel();
    _smsAutoFill.unregisterListener();
    _resendTimer?.cancel();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    final anyFocused = _focusNodes.any((n) => n.hasFocus);
    if (anyFocused) {
      _hiddenFocusNode.requestFocus();
    }
  }

  void _onHiddenOtpChanged() {
    final code = _hiddenOtpController.text;
    if (code.isEmpty) return;
    final digits = code.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < 6 && i < digits.length; i++) {
      _codeControllers[i].text = digits[i];
    }
    if (digits.length >= 6) {
      _hiddenFocusNode.unfocus();
      for (final node in _focusNodes) {
        node.unfocus();
      }
      _verifyOtp();
    }
  }

  void _fillCode(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    _hiddenOtpController.text = digits;
    for (var i = 0; i < 6 && i < digits.length; i++) {
      _codeControllers[i].text = digits[i];
    }
    if (digits.length >= 6) {
      _focusNodes.last.unfocus();
      _hiddenFocusNode.unfocus();
      _verifyOtp();
    } else if (digits.isNotEmpty) {
      _focusNodes[digits.length.clamp(0, 5)].requestFocus();
      _hiddenFocusNode.requestFocus();
    }
  }

  Future<void> _listenForSms() async {
    try {
      _smsSubscription?.cancel();
      await _smsAutoFill.listenForCode();
      _smsSubscription = _smsAutoFill.code.listen((String code) {
        if (code.isNotEmpty && mounted) {
          _fillCode(code);
        }
      });
    } catch (_) {}
  }

  void _startResendTimer() {
    _resendRemaining = _resendDuration;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendRemaining > 0) {
        setState(() => _resendRemaining--);
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  void _onDigitChanged(String value, int index) {
    if (value.isEmpty) {
      if (index > 0) _focusNodes[index - 1].requestFocus();
      return;
    }
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < 6 && i < digits.length; i++) {
        _codeControllers[i].text = digits[i];
      }
      _focusNodes.last.requestFocus();
      return;
    }
    _codeControllers[index].text = value;
    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCode;
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the full 6-digit OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    debugPrint('[VerifyOtp] Verifying OTP');
    debugPrint('[VerifyOtp] URL: ${AppConstants.verifyResetOtp}');
    debugPrint('[VerifyOtp] Body: {userId: ${widget.userId}, otp: $otp}');

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConstants.verifyResetOtp,
        data: {
          'userId': widget.userId,
          'otp': otp,
        },
      );

      final data = response.data ?? {};
      debugPrint('[VerifyOtp] Response status: ${response.statusCode}');
      debugPrint('[VerifyOtp] Response body: $data');

      if (data['success'] == true && mounted) {
        final resetToken = data['resetToken'] as String? ?? '';
        debugPrint('[VerifyOtp] OTP verified, resetToken: $resetToken');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
              userId: widget.userId,
              resetToken: resetToken,
            ),
          ),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = data['message'] as String? ?? 'Invalid OTP';
        });
      }
    } on DioException catch (e) {
      debugPrint('[VerifyOtp] DioException: ${e.message}');
      debugPrint('[VerifyOtp] Response status: ${e.response?.statusCode}');
      debugPrint('[VerifyOtp] Response data: ${e.response?.data}');
      if (mounted) {
        String msg = 'Verification failed';
        if (e.response?.data is Map) {
          msg = (e.response!.data as Map)['message'] as String? ?? msg;
        } else if (e.message != null) {
          msg = e.message!;
        }
        setState(() => _errorMessage = msg);
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    debugPrint('[ResendOtp] Resending OTP');
    debugPrint('[ResendOtp] URL: ${AppConstants.resendOtpUrl}');
    debugPrint('[ResendOtp] Body: {userId: ${widget.userId}}');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConstants.resendOtpUrl,
        data: {'userId': widget.userId},
      );

      final data = response.data ?? {};
      debugPrint('[ResendOtp] Response status: ${response.statusCode}');
      debugPrint('[ResendOtp] Response body: $data');
      final message = data['message'] as String? ?? 'OTP resent';

      if (!mounted) return;
      _startResendTimer();
      _listenForSms();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on DioException catch (e) {
      debugPrint('[ResendOtp] DioException: ${e.message}');
      debugPrint('[ResendOtp] Response data: ${e.response?.data}');
      if (!mounted) return;
      String msg = 'Failed to resend OTP';
      if (e.response?.data is Map) {
        msg = (e.response!.data as Map)['message'] as String? ?? msg;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 50,
      height: 64,
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: kEspressoColor,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: kWarmGrey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: kEspressoColor.withAlpha(25)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: kEspressoColor.withAlpha(25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: kEspressoColor.withAlpha(80), width: 1.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _onDigitChanged(value, index),
      ),
    );
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
                'Verify OTP',
                style: kHeaderStyle,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the 6-digit code sent to your email.',
                style: kSubHeaderStyle.copyWith(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 40),
              Text(
                'OTP CODE',
                style: kLabelTextStyle,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 64,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _hiddenOtpController,
                          focusNode: _hiddenFocusNode,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) => _buildOtpBox(i)),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: kInputFieldHeight,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kEspressoColor,
                    foregroundColor: kIvoryColor,
                    shape: RoundedRectangleBorder(borderRadius: kFullBorderRadius),
                    textStyle: kButtonTextStyle,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('VERIFY OTP'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: kFooterTextStyle.copyWith(
                        fontSize: 13,
                        color: opacity(kEspressoColor, 0.45),
                      ),
                    ),
                    TextButton(
                      onPressed: _resendRemaining > 0 ? null : _resendOtp,
                      child: Text(
                        _resendRemaining > 0
                            ? 'Resend code in 0:${_resendRemaining.toString().padLeft(2, '0')}'
                            : 'Resend Code',
                        style: TextStyle(
                          color: _resendRemaining > 0
                              ? opacity(kEspressoColor, 0.3)
                              : kPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
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
