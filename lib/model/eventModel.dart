import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String? eventId;
  final String title;
  final String description;
  final String location;
  final double price;
  final String imageUrl;
  final DateTime? date;
  final String? category;
  final String createdBy;
  final DateTime? createdAt;

  Event({
    required this.date,
    this.eventId,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.createdBy,
    required this.category,

    required this.createdAt,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? safeDate;
    try {
      safeDate = (data['date'] as Timestamp?)?.toDate();
    } catch (e) {
      print('Invalid or missing event date for doc ${doc.id}');
      safeDate = null;
    }

    DateTime? safeCreatedAt;
    try {
      safeCreatedAt = (data['createdAt'] as Timestamp?)?.toDate();
    } catch (e) {
      print('Invalid or missing createdAt for doc ${doc.id}');
      safeCreatedAt = null;
    }

    return Event(
      eventId: doc.id,
      title: data['eventTitle'] ?? '',
      description: data['eventDescription'] ?? '',
      location: data['eventLocation'] ?? '',
      price: (data['eventPrice'] ?? 0).toDouble(),
      imageUrl: data['eventImage'] ?? '',
      createdBy: data['createdBy'] ?? '',
      category: data['category'] ?? '',
      date: safeDate,
      createdAt: safeCreatedAt,
    );
  }

  // Method to convert an Event object to a Map for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'eventTitle': title,
      'eventDescription': description,
      'eventLocation': location,
      'eventPrice': price,
      'eventImage': imageUrl,
      'date': date,
      'category': category,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}
