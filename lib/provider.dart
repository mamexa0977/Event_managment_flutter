import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_mng_sys/model/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _appUser;  // Store the AppUser data

  AppUser? get appUser => _appUser; // Getter for AppUser

  // Fetch user from Firebase and notify listeners
  Future<void> fetchUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Assuming you have a Firestore collection where you store additional user details
      // You fetch additional user data using the currentUser.uid
      final userDoc = await FirebaseFirestore.instance.collection('user').doc(currentUser.uid).get();

      if (userDoc.exists) {
        // Create AppUser object from fetched data
        _appUser = AppUser(
          uid: currentUser.uid,
          email: currentUser.email,
          firstName: userDoc['firstName'],
          lastName: userDoc['lastName'],
          imageUrl: userDoc['imageUrl'] ?? '',
        );
        notifyListeners();  // Notify listeners when the user is fetched
      }
    }
  }

  // To update or clear user data
  void setUser(AppUser user) {
    _appUser = user;
    notifyListeners();
  }

  void clearUser() {
    _appUser = null;
    notifyListeners();
  }
}
