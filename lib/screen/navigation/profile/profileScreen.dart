import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_mng_sys/provider.dart';
import 'package:event_mng_sys/widget/profilePageUi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<UserProvider>(context).appUser;

    // Check if appUser is null before using its properties
    if (appUser == null) {
      return Center(child: CircularProgressIndicator()); // or any fallback UI
    }

    // Now pass the actual name or other user information
    return profilePage(
      context,
      "${appUser.firstName} ${appUser.lastName}", // Use first and last name
      user!.email!,appUser.imageUrl
    );
  }
}
