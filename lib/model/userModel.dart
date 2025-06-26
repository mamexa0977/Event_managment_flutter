  import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
    final String uid; // Required
    final String? firstName;
    final String? lastName;
    final String? email;
    final String? imageUrl;
    final DateTime? registeredAt;

    AppUser( {
      required this.uid,
      this.firstName,
      this.lastName,
      this.email,
      this.imageUrl,
      this.registeredAt,
    });

    // Convert Firestore DocumentSnapshot into AppUser object
    factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
          DateTime? safeRegisteredAt;
    try {
      safeRegisteredAt = (data['registeredAt'] as Timestamp?)?.toDate();
    } catch (e) {
      print('Invalid or missing createdAt for doc ');
      safeRegisteredAt = null;
    }
      return AppUser(
        uid: uid,
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        imageUrl: data['imageUrl'],
        registeredAt: safeRegisteredAt
      );
    }

    // Convert AppUser object into Map to save in Firestore
    Map<String, dynamic> toMap() {
      return {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'imageUrl': imageUrl,
      };
    }
  }
