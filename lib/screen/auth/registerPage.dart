import 'dart:io';

import 'package:event_mng_sys/widget/authTextField.dart';
import 'package:event_mng_sys/widget/primaryButton.dart';
import 'package:flutter/material.dart';
import 'package:event_mng_sys/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isloading = false;
  File? _image;
  final authService = AuthService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _signUp() {
    try {
      if (_formKey.currentState!.validate()) {
        if (_image != null) {
          setState(() {
            isloading = true;
          });
          signUpUser(
            emailController.text,
            passwordController.text,
            firstNameController.text,
            lastNameController.text,
            _image,
          );
        } else {}
        // Do sign up logic
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  signUpUser(email, password, firstName, lastName, imagefile) {
    authService.signup(
      () {
        // setState() {
        //   isloading = !isloading;
        // }

        // ;
      },
      context,
      email,
      password,
      firstName,
      lastName,
      imagefile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isloading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              // Center the image picker
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      _image != null
                                          ? FileImage(_image!)
                                          : null,
                                  child:
                                      _image == null
                                          ? const Icon(
                                            Icons.add_a_photo,
                                            size: 30,
                                          )
                                          : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Sign up to get started",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),
                            CustomTextField(
                              controller: firstNameController,
                              label: "First Name",
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: lastNameController,
                              label: "Last Name",
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 24),
                            PrimaryButton(
                              text: "Sign Up",
                              onPressed: () {
                                _signUp();
                                // Sign-up logic goes here
                              },
                              color: const Color(0xFF6759FF),
                            ),
                            const SizedBox(height: 16),
                         
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account? "),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Sign in",
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
              ),
    );
  }
}
