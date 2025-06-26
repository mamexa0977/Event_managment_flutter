import 'package:event_mng_sys/model/eventModel.dart';
import 'package:event_mng_sys/screen/navigation/events/event_list/event_detail.dart';
import 'package:flutter/material.dart';
import 'package:event_mng_sys/services/event_service.dart';

class Myevent extends StatefulWidget {
  const Myevent({super.key});

  @override
  State<Myevent> createState() => _MyeventState();
}

class _MyeventState extends State<Myevent> {
  @override
  void initState() {
    super.initState();
    getMyEvent();
    print("init STATEEE");
  }

  List<Event> events = [];
  bool _isLoading = true;

  getMyEvent() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final data = await RegisteredEventService().getMyEvent();
    if (!mounted) return;

    setState(() {
      // _events = data.cast<Map<String, dynamic>>();
      events = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6759FF),
      appBar: AppBar(
        title: const Text(
          'Booked Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF6759FF),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : events.isEmpty
              ? const Center(child: Text("No events found"))
              : cardUi(),

   
    );
  }

  Widget cardUi() {
    return Container(
      //padding: EdgeInsets.all(6),
      decoration: const BoxDecoration(
        // color: Color(0xFF6759FF),
        color: Colors.white,

        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EventDetailScreen(
                        eventId: event.eventId,
                        myevent: true,
                      ), // pass the doc ID
                ),
              );
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
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black54),
                          ],
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
                              "${event.date} ",
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
        },
      ),
    );
  }
}
