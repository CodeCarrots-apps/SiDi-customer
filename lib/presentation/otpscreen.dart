import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constant/constants.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isSubmitting = false;

  String get _otpCode => _codeControllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(String value, int index) {
    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\\D'), '');
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
    if (_otpCode.length != 6 || _otpCode.contains('')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP verified successfully.')));
  }

  void _resendCode() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('A new code has been sent.')));
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
                      'Enter the 6-digit code sent to +1 (555) 0123',
                      style: subtitleStyle,
                    ),
                    const SizedBox(height: 44),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => _buildOtpBox(index),
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _verifyCode,
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
                        child: _isSubmitting
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
                            onPressed: _resendCode,
                            child: const Text(
                              'Resend Code',
                              style: TextStyle(
                                color: kPrimaryColor,
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
