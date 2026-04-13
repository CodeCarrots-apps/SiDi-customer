import 'package:flutter/material.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/controller/logincontroller.dart';
import 'package:sidi/presentation/mainscreen.dart';
import 'package:sidi/presentation/signupscreen.dart';
import 'package:sidi/presentation/widgets/animationtilke.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _loginController = LoginController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginTap() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint('[Login] Sign in button tapped');
    debugPrint(
      '[Login] Email/username entered: ${email.isEmpty ? '<empty>' : email}',
    );
    debugPrint('[Login] Password entered: ${password.isEmpty ? 'no' : 'yes'}');

    if (email.isEmpty || password.isEmpty) {
      debugPrint(
        '[Login] Validation failed: missing email/username or password',
      );
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter both email/username and password.'),
        ),
      );
      return;
    }

    _loginController.email = email;
    _loginController.password = password;
    debugPrint('[Login] Starting login request');

    final result = await _loginController.login();
    debugPrint(
      '[Login] Request finished. success=${result.isSuccess}, message=${result.message}, user=${result.username.isEmpty ? '<unknown>' : result.username}',
    );

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
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
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildForm(context),
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
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            // color: kEspressoColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/images/logo.png', width: 24, height: 24),
        ),
        const SizedBox(height: 16),
        Text('Welcome Back', style: kHeaderStyle, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          'The Art of Personal Care',
          style: kSubHeaderStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        AnimatedInputField(
          'Email or Username',
          'your@email.com',
          label: 'Email or Username',
          placeholder: 'your@email.com',
          controller: _emailController,
          onChanged: (value) {
            debugPrint(
              '[Login] Email/username field changed: ${value.trim().isEmpty ? '<empty>' : value.trim()}',
            );
          },
        ),
        const SizedBox(height: 24),
        AnimatedInputField(
          'Password',
          '••••••••',
          label: 'Password',
          placeholder: 'Enter your password',
          obscureText: true,
          controller: _passwordController,
          onChanged: (value) {
            debugPrint(
              '[Login] Password field changed: ${value.isEmpty ? 'empty' : 'updated'}',
            );
          },
        ),
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
            child: Text(
              'Forgot Password?',
              style: kFooterTextStyle.copyWith(fontSize: 11),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: kInputFieldHeight,
          child: ElevatedButton(
            onPressed: _handleLoginTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: kEspressoColor,
              foregroundColor: kIvoryColor,
              shape: RoundedRectangleBorder(borderRadius: kFullBorderRadius),
              textStyle: kButtonTextStyle,
            ),
            child: const Text('LOG IN'),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: Text('Join Now', style: kLinkTextStyle),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(
          color: kEspressoColor.withValues(alpha: 0.1),
          thickness: 1,
          indent: 60,
          endIndent: 60,
        ),
        const SizedBox(height: 12),
        Text(
          'Privacy & Terms',
          textAlign: TextAlign.center,
          style: kFooterTextStyle.copyWith(fontSize: 9, letterSpacing: 2),
        ),
      ],
    );
  }
}
