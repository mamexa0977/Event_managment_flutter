import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_mng_sys/model/userModel.dart';
import 'package:event_mng_sys/provider.dart';
import 'package:event_mng_sys/widget/profilePageUi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:event_mng_sys/screen/auth/loginPage.dart'; // Ensure this import is correct
import 'package:event_mng_sys/utils/nagivation_helper.dart';
import 'package:event_mng_sys/utils/snack_helper.dart';
import 'package:provider/provider.dart'; // Navigation helper

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final User? logger = FirebaseAuth.instance.currentUser;
  final _auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  bool isEditing = false;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  dynamic userdocs = {};
  // Map<String, dynamic>? userdocs;

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  Future<void> getData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) {
          snackMessage(context, "No user is signed in", Colors.red);
        }
        return;
      }

      final userDoc = await firestore.collection("user").doc(user.uid).get();

      if (!userDoc.exists) {
        if (mounted) {
          snackMessage(context, "User data not found", Colors.red);
        }
        return;
      }

      if (!mounted) return;

      setState(() {
        userdocs = userDoc.data()!;
        isLoading = false;
      });
    } catch (e, stack) {
      print("Error: $e");
      print(stack);
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // Function to sign the user out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      navigateAndReplace(context, const LoginScreen()); // Use navigation helper
    } catch (e) {
      print("Error signing out: $e");
      snackMessage(
        context,
        "Error signing out: $e",
        Colors.red,
      ); // Show error message
    }
  }

  // Function to send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (logger != null) {
        await logger!.sendEmailVerification();
        snackMessage(
          context,
          "Verification email sent",
          Colors.green,
        ); // Show success message
      }
    } catch (e) {
      print("Error sending verification: $e");
      snackMessage(
        context,
        "Error sending verification: $e",
        Colors.red,
      ); // Show error message
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body:
          logger != null && logger!.emailVerified
              ? _buildVerifiedUserUI() // UI for verified user
              : _buildUnverifiedUserUI(), // UI for unverified user
    );
  }

  // optional to display/edit

  Widget _buildVerifiedUserUI() {
    if (userdocs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // Set initial values once when entering edit mode
    if (isEditing) {
      firstNameController.text = userdocs['firstName'] ?? '';
      lastNameController.text = userdocs['lastName'] ?? '';
      emailController.text = logger?.email ?? '';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "User Profile",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(isEditing ? Icons.close : Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                isEditing
                    ? Column(
                      children: [
                        _buildEditableField("First Name", firstNameController),
                        const SizedBox(height: 10),
                        _buildEditableField("Last Name", lastNameController),
                        const SizedBox(height: 10),
                        _buildEditableField(
                          "Email",
                          emailController,
                          enabled: false,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveProfileChanges,
                          child: const Text("Save"),
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        _buildInfoRow("Email", logger?.email ?? ''),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                          "First Name",
                          userdocs['firstName'] ?? 'N/A',
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                          "Last Name",
                          userdocs['lastName'] ?? 'N/A',
                        ),
                      ],
                    ),
                const SizedBox(height: 30),
                _buildSignOutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _saveProfileChanges() async {
    try {
      final uid = _auth.currentUser!.uid;
      await firestore.collection("user").doc(uid).update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
      });
      final updatedUser = AppUser(
        uid: uid,
        email: _auth.currentUser!.email,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        imageUrl:
            _auth.currentUser!.photoURL ??
            '', // Keep the existing image URL or use the default
      );
      Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
      snackMessage(context, "Profile updated!", Colors.green);

      // Refresh UI data
      await getData();

      setState(() {
        isEditing = false;
      });
    } catch (e) {
      snackMessage(context, "Error updating profile: $e", Colors.red);
    }
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$title:", style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }

  // Widget for UI when user is not verified
  Widget _buildUnverifiedUserUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSignOutButton(), // Sign-out button
          _buildVerifyButton(), // Verify button
        ],
      ),
    );
  }

  // Sign-out button
  Widget _buildSignOutButton() {
    return ElevatedButton(onPressed: signOut, child: const Text("Sign Out"));
  }

  // Verify button
  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: sendEmailVerification,
      child: const Text("Resend Verification Email"),
    );
  }
}
