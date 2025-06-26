import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_mng_sys/model/eventModel.dart';
import 'package:event_mng_sys/screen/navigation/profile/ownEvent/ownEventDetail.dart';
import 'package:event_mng_sys/services/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnEvent extends StatefulWidget {
  const OwnEvent({super.key});

  @override
  State<OwnEvent> createState() => _OwnEventState();
}

class _OwnEventState extends State<OwnEvent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  List<Event> _events = [];
  bool _isLoading = true;
  final EventListService _eventService = EventListService();

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final events = await getUserEvents(); // Use the service to fetch events
      if (!mounted) return; // Avoid setState after widget dispose
      setState(() {
        _events = events;
        _isLoading = false; // Stop loading once the events are fetched
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Stop loading if there's an error
      });
      // Handle error (you can show a SnackBar or dialog if needed)
      print("Error: $e");
    }
  }

  // Function to fetch events created by the current user
  Future<List<Event>> getUserEvents() async {
    try {
      // Query the events collection where 'createdBy' field matches the userId
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('events')
              .where('createdBy', isEqualTo: userId)
              .get();

      // Map the results to a list of Event objects
      final events =
          querySnapshot.docs.map((doc) {
            final event = Event.fromFirestore(doc);

            // final event = doc.data();
            print("🔥 Event fetched: ${event.title}");
            event.eventId = doc.id; // Add document ID manually

            // print("Fetched event ID: ${event['id']}");
            return event;
          }).toList();
      return events;
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  List<Widget> cardUi() {
    return _events.map((event) {
      return GestureDetector(
        onTap: () async {
          print(event.eventId);
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OwnEventDetail(eventId: event.eventId),
            ),
          );

          if (shouldRefresh == true) {
            fetchEvents(); // Refresh only if needed
          }
        },

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  event.imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 60,
                  left: 16,
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${event.date}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          event.location,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Own Events")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _events.isEmpty
              ? const Center(child: Text("No events found"))
              : CustomScrollView(
                slivers: [
                  SliverList(delegate: SliverChildListDelegate(cardUi())),
                ],
              ),
    );
  }
}
