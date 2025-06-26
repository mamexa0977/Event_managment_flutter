import 'package:event_mng_sys/widget/authTextField.dart';
import 'package:event_mng_sys/widget/primaryButton.dart';
import 'package:flutter/material.dart';
import 'package:event_mng_sys/screen/auth/resetPage.dart';
import 'package:event_mng_sys/screen/auth/registerPage.dart';

import 'package:event_mng_sys/services/auth_service.dart';
import 'package:event_mng_sys/utils/nagivation_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isloading = false;
  final authService = AuthService();

  signInUser(email, password) {
    authService.signin(
      () {
        setState(() {
          isloading = !isloading;
        });
      },
      context,
      email,
      password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isloading
              ? Scaffold(body: Center(child: CircularProgressIndicator()))
              : SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Login to your account",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          CustomTextField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: passwordController,

                            label: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                navigateToScreen(context, Reset());
                              },
                              child: const Text("Forgot Password?"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            text: "Login",
                            onPressed:
                                () => {
                                  signInUser(
                                    emailController.text,
                                    passwordController.text,
                                  ),
                                },
                            color: const Color(0xFF6759FF),
                          ),
                          const SizedBox(height: 16),

                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don’t have an account? "),
                              GestureDetector(
                                onTap: () {
                                  navigateToScreen(context, SignUpPage());
                                },
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6759FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
