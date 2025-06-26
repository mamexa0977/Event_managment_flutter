import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_mng_sys/screen/homeScreen.dart';
import 'package:event_mng_sys/utils/nagivation_helper.dart';
import 'package:event_mng_sys/utils/snack_helper.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final User? logger = FirebaseAuth.instance.currentUser;

  Future<void> sendEmailVerification() async {
    try {
      if (logger != null) {
        await logger!.sendEmailVerification();
        await logger!.reload();
        snackMessage(context, "Please check your email !", Colors.green);

        if (logger!.emailVerified) {
          navigateToScreen(context, HomeScreen());
        } else {
          // snackMessage(context, "Please verify your email first.", Colors.red);
        }
      }
    } catch (e) {
      snackMessage(context, "Error sending verification: $e", Colors.red);
      print(e);
    }
  }

  Future<void> checkVerificationStatus() async {
    try {
      if (logger != null) {
        await logger!.reload();
        final user = FirebaseAuth.instance.currentUser;
        setState(() {});
        if (user!.emailVerified) {
          snackMessage(context, "Sign-in success!", Colors.green);
          navigateToScreen(context, HomeScreen());
        } else {
          snackMessage(
            context,
            "You didn't verify your email yet.",
            Colors.red,
          );
        }
      }
    } catch (e) {
      snackMessage(context, "Sign-in failed: $e", Colors.red);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Verify Email",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Click the button to receive a verification link in your email.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: sendEmailVerification,
                      icon: const Icon(
                        Icons.send_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Send Verification Email",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6759FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: checkVerificationStatus,
                      icon: const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Check Verification Status",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
