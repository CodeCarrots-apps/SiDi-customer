import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/controller/signupcontroller.dart';
import 'package:sidi/presentation/loginscreen.dart';
import 'package:sidi/presentation/otpscreen.dart';
import 'package:sidi/presentation/widgets/animationtilke.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // final RegisterController _registerController = RegisterController();
  final RegisterController _registerController = Get.put(RegisterController());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  static const String _phonePrefix = '+91';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController.value = TextEditingValue(
      text: _phonePrefix,
      selection: TextSelection.collapsed(offset: _phonePrefix.length),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUpTap() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.replaceAll(_phonePrefix, '').trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final referralCode = _referralCodeController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all fields before signing up.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _registerController.name = name;
    _registerController.email = email;
    // _registerController.phone = phone;
    _registerController.phone = _phoneController.text.trim();
    _registerController.password = password;
    _registerController.confirmPassword = confirmPassword;
    _registerController.referralCode = referralCode;

    final result = await _registerController.register();

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.isSuccess) {
      TextInput.finishAutofillContext();
      if (!mounted) return;
      if (result.requiresOtp) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              userId: result.userId,
              contact: phone,
              contactType: 'phone',
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
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
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
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
                  // const SizedBox(height: 6),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildForm(),
                  const SizedBox(height: 32),
                  _buildFooter(context),
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
        SizedBox(
          width: 68,
          height: 68,
          child: Image.asset('assets/images/logo.png', width: 24, height: 24),
        ),
        const SizedBox(height: 16),
        Text(
          'Create Account',
          style: kHeaderStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Join Our Private Circle',
          style: kSubHeaderStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return AutofillGroup(
      child: Column(
        children: [
          _buildInputField(
            'Full Name',
            'Julianne Moore',
            controller: _nameController,
            autofillHints: const [AutofillHints.name],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Email',
            'name@domain.com',
            inputType: TextInputType.emailAddress,
            controller: _emailController,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Phone',
            '9876543210',
            inputType: TextInputType.phone,
            controller: _phoneController,
            inputFormatters: [
              PrefixTextInputFormatter(_phonePrefix),
            ],
            autofillHints: const [AutofillHints.newUsername, AutofillHints.telephoneNumber],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Password',
            '••••••••',
            obscureText: true,
            controller: _passwordController,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Confirm Password',
            '••••••••',
            obscureText: true,
            controller: _confirmPasswordController,
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Referral Code',
            'REFERRAL_CODE_HERE',
            controller: _referralCodeController,
          ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: kInputFieldHeight,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSignUpTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: kEspressoColor,
              foregroundColor: kIvoryColor,
              shape: RoundedRectangleBorder(borderRadius: kFullBorderRadius),
              textStyle: kButtonTextStyle,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kIvoryColor),
                    ),
                  )
                : const Text('SIGN UP'),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text.rich(
            TextSpan(
              text: 'By signing up, you agree to our ',
              style: kFooterTextStyle.copyWith(fontSize: 10, letterSpacing: 2),
              children: const [
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),);
  }

  Widget _buildInputField(
    String label,
    String placeholder, {
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: kLabelTextStyle),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: inputType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: kInputHintStyle,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: kEspressoColor.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: kEspressoColor.withValues(alpha: 0.4),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Already have an account?', style: kFooterTextStyle),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Sign In', style: kLinkTextStyle),
            ),
          ],
        ),
      ],
    );
  }
}


