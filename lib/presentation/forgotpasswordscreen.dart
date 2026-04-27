import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/presentation/widgets/animationtilke.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });

      // After showing success, go back after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kIvoryColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: kIvoryColor,
            surfaceTintColor: kIvoryColor,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, size: 18),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kHorizontalPadding,
                vertical: kVerticalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  if (!_isSuccess) _buildForm() else _buildSuccessMessage(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Image.asset('assets/images/logo.png', width: 24, height: 24),
        ),
        const SizedBox(height: 24),
        Text(
          'Reset Password',
          style: kHeaderStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your email to receive a password reset link',
          style: kSubHeaderStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AnimatedInputField(
          'Email Address',
          'your@email.com',
          label: 'Email Address',
          placeholder: 'your@email.com',
          controller: _emailController,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: kInputFieldHeight,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handlePasswordReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: kEspressoColor,
              foregroundColor: kIvoryColor,
              shape: RoundedRectangleBorder(borderRadius: kFullBorderRadius),
              textStyle: kButtonTextStyle,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('SEND RESET LINK'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.check, size: 32, color: Colors.green.shade700),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Check Your Email',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: kCharcoalColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}. Check your email and follow the link to reset your password.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: kWarmGrey600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
