import 'package:event_mng_sys/model/eventModel.dart';
import 'package:flutter/material.dart';
import 'package:event_mng_sys/services/event_service.dart';

class EventDetailScreen extends StatefulWidget {
  final String? eventId;
  final bool myevent;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.myevent,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int ticketCount = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Event Detail'), centerTitle: true),
      body: FutureBuilder<Event?>(
        future: EventDetailService().fetchEventDetail(widget.eventId, context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }

          final event = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  topUi(event),

                  const SizedBox(height: 24),
                  description(event),
                  const SizedBox(height: 24),
                  if (!widget.myevent) ...[
                    ticketUi(),
                    const SizedBox(height: 24),
                    priceUi(event.price),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget topUi(Event event) {
    return ClipRRect(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${event.date}", style: TextStyle(color: Colors.white)),
                  Text(event.location, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget description(dynamic event) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Event",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(event.description),
            ],
          ),
        ),
      ),
    );
  }

  Widget ticketUi() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  ticketCount++;
                });
              },
              child: const Icon(
                Icons.add_circle,
                color: Colors.green,
                size: 30,
              ),
            ),
            Text(
              ticketCount.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (ticketCount > 1) {
                    ticketCount--;
                  }
                });
              },
              child: const Icon(
                Icons.remove_circle,
                color: Colors.red,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget priceUi(double eventPrice) {
    double totalPrice = eventPrice * ticketCount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Amount: \$${totalPrice.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              EventDetailService().register(widget.eventId, context);
            },
            child: const Text("Book Now", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
