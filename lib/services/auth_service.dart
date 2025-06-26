// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:event_mng_sys/screen/auth/verifyPage.dart';
import 'package:event_mng_sys/screen/homeScreen.dart';
import 'package:event_mng_sys/utils/snack_helper.dart';
import 'package:event_mng_sys/utils/nagivation_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Sign-in function
  signin(
    Function updateState,
    BuildContext context,
    String email,
    String password,
  ) async {
    updateState();
    try {
      UserCredential usercred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("User successfully logged in: ${email}");

      snackMessage(context, "Successfully signed-in!", Colors.green);

      // Check if email is verified and navigate accordingly
      if (usercred.user!.emailVerified) {
        navigateAndReplace(context, HomeScreen());
      } else {
        navigateAndReplace(context, Verify());
      }
    } catch (e) {
      print(e);
      snackMessage(context, "Sign-in failed: $e", Colors.red);
    } finally {
      updateState();
    }
  }

  Future<String> uploadImageToStorage(File? imageFile, String path) async {
    if (imageFile == null) throw Exception('Image file is null');
    print(imageFile);

    final supabase = Supabase.instance.client;

    // Upload the file to your Supabase Storage bucket with a custom path
    final response = await supabase.storage
        .from('uploads')
        .upload(
          path, // Full path like 'profile_images/user123.png'
          imageFile,
          fileOptions: const FileOptions(upsert: true), // overwrite if exists
        );
    print(response);

    if (response.isEmpty) throw Exception('Upload failed');

    // Get public URL
    final url = supabase.storage.from('uploads').getPublicUrl(path);
    print(url);

    return url;
  }

  // Sign-up function
  signup(
    Function updateState,
    BuildContext context,
    String email,
    String password,
    String firstName,
    String lastName,
    File? imageFile,
  ) async {
    updateState();
    try {
      UserCredential userinfo = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("User successfully registered: ${email}");
      final _imageUrl = await uploadImageToStorage(
        imageFile,
        "eventImages/${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
      final userdoc = await firestore
          .collection("user")
          .doc(userinfo.user!.uid)
          .set({
            "email": email,
            "imageUrl": _imageUrl,
            "firstName": firstName,
            "lastName": lastName,
          });

      snackMessage(context, "Sign-up successful", Colors.green);

      // Navigate to verification screen after sign-up
      navigateToScreen(context, Verify());
    } catch (e) {
      print(e);
      snackMessage(context, "Sign-up failed: $e", Colors.red);
    } finally {
      updateState();
    }
  }
//  Future<void> googlesignin(BuildContext context) async {
//     try {
//         final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//       // Step 1: Trigger Google Sign-In flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return;

//       // Step 2: Check if email exists in Firebase
//       final String email = googleUser.email;
//       final methods = await _auth.fetchSignInMethodsForEmail(email);
//       if (methods.isEmpty) {
//         // Email not registered, show error
//         _showErrorMessage(context, 'Account not registered. Please sign up first.');
//         return;
//       }

//       // Step 3: Obtain auth details from Google
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Step 4: Sign in to Firebase with Google credentials
//       final UserCredential userCredential = await _auth.signInWithCredential(credential);

//       // Successfully signed in
//       // Navigate to home screen or next step
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'account-exists-with-different-credential') {
//         // Handle existing account with different provider
//         _showErrorMessage(
//           context,
//           'An account already exists with ${e.email}. '
//           'Sign in with your existing method to link accounts.',
//         );
//       } else {
//         _showErrorMessage(context, 'Error signing in: ${e.message}');
//       }
//     } catch (e) {
//       _showErrorMessage(context, 'Error signing in: $e');
//     }
//   }

//   void _showErrorMessage(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
}
