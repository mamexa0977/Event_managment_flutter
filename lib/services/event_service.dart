import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_mng_sys/model/eventModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:event_mng_sys/utils/snack_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDetailService {
  register(dynamic id, BuildContext context) async {
    try {
      final eventUser = await FirebaseFirestore.instance;
      final currentUser = FirebaseAuth.instance.currentUser;
      await eventUser
          .collection("events") // main folder is event// gaming
          .doc(id)
          .collection("registeredUsers")
          .doc(
            currentUser!.uid,
          ) // add current user inside registered folder with his information
          .set({
            // first value,
            "email":
                currentUser
                    .email, // All Event--> one event folder --> All user-->currentuserfoldeer --> userfile
            "userId": currentUser.uid, //TODO use user info from database
            "registeredAt": FieldValue.serverTimestamp(),
          });

      // ignore: unused_local_variable
      final useer = await eventUser
          .collection("user")
          .doc(currentUser.uid)
          .collection("registeredEvents")
          .doc(id)
          .set({"eventId": id, "registeredAt": FieldValue.serverTimestamp()});
      print("Successful Registration");
      snackMessage(context, "Successful Registration", Colors.green);
    } catch (e) {
      snackMessage(context, "UnSuccessful Registration $e", Colors.red);

      print(e);
    }
  }

  Future<Event?> fetchEventDetail(dynamic id, BuildContext context) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('events').doc(id).get();

      if (doc.exists) {
        // return doc.data(); // This returns {title: ..., description: ...}
        final data = Event.fromFirestore(doc);


        return data;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }
}

class EventCreateService {
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

  Future<void> createEvent(
    BuildContext context,
    Function startState,
    Function updateState,
    File? imageFile,
    Event? event, // This will be the Event object you pass
  ) async {
    startState();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      snackMessage(context, "User not logged in", Colors.red);
      return;
    }

    // Check if event or imageFile is null, if so show a message
    if (event == null || imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      // Upload the image to Firebase Storage
      final _imageUrl = await uploadImageToStorage(
        imageFile,
        "eventImages/${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      // Set the event properties, using the passed `event` and the uploaded image URL
      final eventDoc = FirebaseFirestore.instance.collection("events").doc();
      final eventId = eventDoc.id;

      // Create a new event with the image URL and current timestamp
      await eventDoc.set({
        "eventId": eventId,
        "eventTitle": event.title.trim(),
        "eventDescription": event.description.trim(),
        "eventLocation": event.location.trim(),
        "eventPrice": event.price,
        "eventImage": _imageUrl,
        "date": event.date,
        "category": event.category,
        "createdBy": user.uid,
        "createdAt":
            Timestamp.now(), // Using Timestamp.now() for current timestamp
      });

      // Optionally, add the user as registered for the event
      await eventDoc.collection("registeredUsers").doc(user.uid).set({
        "email": user.email,
        "userId": user.uid, //TODO use user info from database
        "registeredAt": FieldValue.serverTimestamp(),
      });

      snackMessage(context, "Event created successfully", Colors.green);
    } catch (e) {
      snackMessage(context, "Error: $e", Colors.red);
    } finally {
      updateState();
    }
  }
}

class EventListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Event>> fetchEvents({
    String? searchText,
    String? selectedCategory,
  }) async {
    try {
      Query query = _firestore.collection('events');

      // Apply category filter if selected
      if (selectedCategory != null && selectedCategory.isNotEmpty) {
        query = query.where('category', isEqualTo: selectedCategory);
      }

      // Apply search filter (e.g. search by title)
      if (searchText != null && searchText.isNotEmpty) {
        query = query.orderBy('eventTitle').startAt([searchText]).endAt([
          searchText + '\uf8ff',
        ]);
      }

      final querySnapshot = await query.get();

      final now = DateTime.now();

      final events =
          querySnapshot.docs
              .map((doc) {
                final event = Event.fromFirestore(doc);
                event.eventId = doc.id;
                return event;
              })
              .where((event) {
                // Make sure the event date is today or in the future
                return event.date!.isAfter(now) ||
                    event.date!.isAtSameMomentAs(now);
              })
              .toList();

      return events;
    } catch (e) {
      print("Error fetching events: $e");
      throw Exception("Error fetching events: $e");
    }
  }
}

class RegisteredEventService {
  Future<List<Event>> getMyEvent() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final registeredSnapshot =
          await FirebaseFirestore.instance
              .collection("user")
              .doc(user!.uid)
              .collection("registeredEvents")
              .get();

      List<Event> validEvents = [];

      for (var doc in registeredSnapshot.docs) {
        final eventId = doc.id;

        final eventDoc =
            await FirebaseFirestore.instance
                .collection("events")
                .doc(eventId)
                .get();

        if (eventDoc.exists) {
          final event = Event.fromFirestore(eventDoc); // ✅ Fixed here
          event.eventId = eventId;
          validEvents.add(event);
        }
      }

      return validEvents;
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }
}
