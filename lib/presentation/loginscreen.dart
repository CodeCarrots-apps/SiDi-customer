import 'package:flutter/material.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/presentation/signupscreen.dart';
import 'package:sidi/presentation/widgets/animationtilke.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                  const SizedBox(height: 40),
                  _buildForm(context),
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
        Text('Welcome Back', style: kHeaderStyle, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text('The Art of Personal Care', style: kSubHeaderStyle, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        AnimatedInputField('Email or Username', 'your@email.com', label: 'Email or Username', placeholder: 'your@email.com',),
        const SizedBox(height: 24),
        AnimatedInputField('Password', '••••••••', label: 'Password', placeholder: 'Enter your password', obscureText: true,),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('Forgot Password?', style: kFooterTextStyle.copyWith(fontSize: 11)),
          ),
        ),
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
            child: const Text('SIGN IN'),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String placeholder, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: kLabelTextStyle),
        const SizedBox(height: 4),
        TextField(
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
            Text('New here?', style: kFooterTextStyle),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
              },
              child: Text('Join Now', style: kLinkTextStyle),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: kEspressoColor.withOpacity(0.1), thickness: 1, indent: 60, endIndent: 60),
        const SizedBox(height: 12),
        Text('Privacy & Terms', textAlign: TextAlign.center, style: kFooterTextStyle.copyWith(fontSize: 9, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildTopGradient() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 128,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kEspressoColor.withOpacity(0.02), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }
}
