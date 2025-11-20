import 'dart:async';
//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboarding_main_page.dart';
import 'package:rent_a_cart/pages/login/widgets/login_header.dart';
import 'package:rent_a_cart/pages/login/widgets/custom_text_field.dart';
import 'package:rent_a_cart/pages/login/widgets/login_button.dart';
import 'package:rent_a_cart/pages/login/widgets/login_divider.dart';
import 'package:rent_a_cart/pages/login/widgets/social_login_button.dart';
import 'package:rent_a_cart/pages/login/widgets/sign_up_prompt.dart';

import 'package:google_sign_in/google_sign_in.dart' as g_sign_in;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final g_sign_in.GoogleSignIn _googleSignIn = g_sign_in.GoogleSignIn.instance;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _googleSignIn.initialize(
      serverClientId:
          '743286900860-ss48fqp9cl44479s7cp7b9iekvritcro.apps.googleusercontent.com',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryRadialGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LoginHeader(),
                    const SizedBox(height: 48),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    LoginButton(onPressed: () {}, isLoading: _isLoading),
                    const SizedBox(height: 18),
                    const LoginDivider(),
                    const SizedBox(height: 20),
                    SocialLoginButton(
                      icon: Icons.g_mobiledata,
                      label: 'Continue with Google',
                      onPressed: _handleGoogleSignIn,
                    ),
                    const SizedBox(height: 12),
                    SocialLoginButton(
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      onPressed: () {
                        // Apple Sign In 
                      },
                    ),
                    const SizedBox(height: 32),
                    SignUpPrompt(onSignUpTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final idToken = googleAuth.idToken;


      if (idToken == null) {
        throw 'No ID Token found. Make sure you set the serverClientId correctly.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: null, 
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardMainPage()),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error occurred: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
