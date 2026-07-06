import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sidi/controller/otpcontroller.dart';
import 'package:sidi/utils/token_storage.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../constant/constants.dart';
import 'mainscreen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    Key? key,
    required this.userId,
    this.contact = '',
    this.contactType = 'phone',
  }) : super(key: key);

  final String userId;
  final String contact;
  final String contactType;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final OtpController _otpController = Get.put(OtpController());
  final SmsAutoFill _smsAutoFill = SmsAutoFill();
  final TextEditingController _hiddenOtpController = TextEditingController();
  final FocusNode _hiddenFocusNode = FocusNode();
  StreamSubscription<String>? _smsSubscription;
  bool _isSubmitting = false;

  static const int _resendDuration = 30;
  int _resendRemaining = 0;
  Timer? _resendTimer;

  String get _otpCode => _codeControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _otpController.userId = widget.userId;
    _otpController.type = widget.contactType == 'phone' ? 'phone' : 'email';
    _startResendTimer();
    _listenForSms();
    _hiddenOtpController.addListener(_onHiddenOtpChanged);
    for (final node in _focusNodes) {
      node.addListener(_onFocusChanged);
    }
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
      _verifyCode();
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
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
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
      _verifyCode();
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
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length == 6) {
        for (var i = 0; i < 6; i++) {
          _codeControllers[i].text = digits[i];
        }
        _focusNodes.last.requestFocus();
        return;
      }
      _codeControllers[index].text = digits.characters.first;
    }

    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  Future<void> _verifyCode() async {
    if (_otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _otpController.otp = _otpCode;
    final result = await _otpController.verifyOtp();

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result.isSuccess) {
      await TokenStorage.saveToken(result.token);
      TextInput.finishAutofillContext();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  Future<void> _resendCode() async {
    final result = await _otpController.resendOtp();
    if (!mounted) return;
    _startResendTimer();
    _listenForSms();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
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
            borderSide: BorderSide(
              color: kEspressoColor.withAlpha(80),
              width: 1.5,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _onDigitChanged(value, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = kHeaderStyle.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
    );
    final subtitleStyle = kSubHeaderStyle.copyWith(
      fontSize: 16,
      color: opacity(kEspressoColor, 0.6),
      fontWeight: FontWeight.w400,
    );

    final displayContact = widget.contact.isNotEmpty
        ? widget.contact
        : (widget.contactType == 'phone' ? 'your phone' : 'your email');

    return Scaffold(
      backgroundColor: kIvoryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kHorizontalPadding,
                vertical: 26,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: kWarmGrey50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: kEspressoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: kHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verify Identity', style: headerStyle),
                    const SizedBox(height: 16),
                    Text(
                      'Enter the 6-digit code sent to $displayContact',
                      style: subtitleStyle,
                    ),
                    const SizedBox(height: 44),
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
                                autofillHints: const [
                                  AutofillHints.oneTimeCode,
                                ],
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              6,
                              (index) => _buildOtpBox(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            (_isSubmitting || _otpController.isLoading)
                                ? null
                                : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kEspressoColor,
                          foregroundColor: kIvoryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          textStyle: kButtonTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: (_isSubmitting || _otpController.isLoading)
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    kIvoryColor,
                                  ),
                                ),
                              )
                            : const Text('Verify & Sign In'),
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
                            onPressed: (_otpController.isLoading ||
                                    _resendRemaining > 0)
                                ? null
                                : _resendCode,
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
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: kHorizontalPadding,
                right: kHorizontalPadding,
                bottom: 24,
                top: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield,
                    size: 16,
                    color: opacity(kEspressoColor, 0.4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SECURE VERIFICATION',
                    style: kFooterTextStyle.copyWith(
                      fontSize: 11,
                      letterSpacing: 1.8,
                      color: opacity(kEspressoColor, 0.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
