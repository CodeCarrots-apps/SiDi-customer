import 'package:flutter/material.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/presentation/loginscreen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kIvoryColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding, vertical: kVerticalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildForm(),
                  const SizedBox(height: 32),
                  _buildFooter(context),
                ],
              ),
            ),
            _buildTopGradient(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: kEspressoColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.spa, color: kEspressoColor.withOpacity(0.4), size: 24),
        ),
        const SizedBox(height: 16),
        Text('Create Account', style: kHeaderStyle, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text('Join Our Private Circle', style: kSubHeaderStyle, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildInputField('Full Name', 'Julianne Moore'),
        const SizedBox(height: 16),
        _buildInputField('Email', 'name@domain.com', inputType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildInputField('Password', '••••••••', obscureText: true),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: kInputFieldHeight,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kEspressoColor,
              foregroundColor: kIvoryColor,
              shape: RoundedRectangleBorder(borderRadius: kFullBorderRadius),
              textStyle: kButtonTextStyle,
            ),
            child: const Text('SIGN UP'),
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
    );
  }

  Widget _buildInputField(String label, String placeholder, {TextInputType inputType = TextInputType.text, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: kLabelTextStyle),
        const SizedBox(height: 4),
        TextField(
          keyboardType: inputType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: kInputHintStyle,
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kEspressoColor.withOpacity(0.1))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kEspressoColor.withOpacity(0.4))),
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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

  Widget _buildTopGradient() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 192,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kEspressoColor.withOpacity(0.03), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }
}
