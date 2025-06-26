import 'package:event_mng_sys/screen/auth/loginPage.dart';
import 'package:event_mng_sys/screen/navigation/profile/ownEvent/ownEventlist.dart';
import 'package:event_mng_sys/screen/navigation/profile/userProfile.dart';
import 'package:event_mng_sys/utils/nagivation_helper.dart';
import 'package:event_mng_sys/utils/snack_helper.dart';
import 'package:event_mng_sys/widget/primaryButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget profilePage(
  BuildContext context,
  String? name,
  String? email,
  String? image,
) {
  Future<void> signOut() async {
    try {
      final _auth = FirebaseAuth.instance;

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

  return Scaffold(
    appBar: AppBar(title: Text('Profile'), centerTitle: true),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                image!,
              ), // You can replace this with your own image
            ),
            SizedBox(height: 16),

            // Name
            Text(
              name!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // Email or other detail
            Text(
              email!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),

            // Divider
            Divider(thickness: 1),

            // Info Tiles
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Account Details'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                navigateToScreen(context, UserProfile());
              },
            ),
            ListTile(
              leading: Icon(Icons.swipe_left),
              title: Text('Own Event'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                navigateToScreen(context, OwnEvent());
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "Log Out",
                onPressed: () {
                  // Function to sign the user out
                  signOut();
                },
                color: const Color(0xFF6759FF),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
