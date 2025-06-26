import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_mng_sys/model/eventModel.dart';
import 'package:event_mng_sys/model/userModel.dart';
import 'package:event_mng_sys/screen/navigation/profile/ownEvent/modifyEvent.dart';
import 'package:event_mng_sys/screen/navigation/profile/profileScreen.dart';
import 'package:event_mng_sys/services/event_service.dart';
import 'package:event_mng_sys/utils/nagivation_helper.dart';
import 'package:event_mng_sys/utils/snack_helper.dart';
import 'package:event_mng_sys/widget/customButton.dart';
import 'package:event_mng_sys/widget/customTextfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class OwnEventDetail extends StatefulWidget {
  final String? eventId;

  const OwnEventDetail({super.key, required this.eventId});

  @override
  State<OwnEventDetail> createState() => _OwnEventDetailState();
}

class _OwnEventDetailState extends State<OwnEventDetail> {
  Widget topUi(Event event) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        // height: 50,
        // height: MediaQuery.of(context).size.height * 0.5,
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
                    Text(event.location, style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  DateTime? _selectedDateTime;
  List<AppUser> _users = [];

  String? _selectedOption;

  bool isEditing = false;

  final List<String> _options = [
    'Gaming',
    'Basketball',
    'Education',
    'Fitness',
    'Food',
  ];

  bool _isLoading = false;
  File? imageFile;
  fetchData() async {
    final users = await fetchUsers(widget.eventId);
    setState(() {
      _users = users;
    });
  }

  void _pickDateTime() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2020),
      maxTime: DateTime(2030),
      onConfirm: (date) {
        setState(() {
          _selectedDateTime = date;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
  }

  Future<List<AppUser>> fetchUsers(String? eventId) async {
    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      Query query = _firestore
          .collection('events')
          .doc(eventId)
          .collection("registeredUsers");

      final querySnapshot = await query.get();

      final users =
          querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final user = AppUser.fromFirestore(data, doc.id);
            print("🔥 Event fetched: ${user.email}");
            return user;
          }).toList();

      return users;
    } catch (e) {
      print("Error fetching events: $e");
      throw Exception("Error fetching events: $e");
    }
  }

  List<Widget> cardUi() {
    return _users.map((user) {
      return GestureDetector(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 150, // 👈 Add a height to constrain the Stack
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6759FF),
                    Color(0xFF9D78FF),
                  ], // Start and end colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 60,
                    left: 16,
                    child: Text(
                      "Email: ${user.email}",
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
                      child: Text(
                        "Registered At ${user.registeredAt}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> updateEvent(String eventId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .update({
            'eventTitle': titleController.text.trim(),
            'eventDescription': descriptionController.text.trim(),
            'eventLocation': locationController.text.trim(),
            'eventPrice': double.parse(priceController.text.trim()),
            'date': _selectedDateTime,
            'category': _selectedOption,
          });
      // Return "true" to signal data changed
      int count = 0;
      Navigator.of(context).popUntil((route) {
        return count++ == 2; // Pops two screens
      });

      snackMessage(context, "Event updated successfully!", Colors.green);
    } catch (e) {
      snackMessage(context, "Failed to update event: $e", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
      //Navigator.pop(context, true); // Return "true" to signal data changed
    }
  }

  Widget dateMenuUi() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // DateTime Picker Button
          ElevatedButton(
            onPressed: _pickDateTime,
            child: Text(
              _selectedDateTime == null
                  ? 'Pick Date & Time'
                  : 'Picked: ${_selectedDateTime.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),

          // Dropdown Menu
          DropdownButtonFormField<String>(
            value: _selectedOption,
            hint: Text('Select an Option'),
            items:
                _options.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  bool _isInitialized = false;

  void initializeControllers(Event event) {
    if (_isInitialized) return;

    titleController.text = event.title ?? '';
    descriptionController.text = event.description ?? '';
    locationController.text = event.location ?? '';
    priceController.text = event.price.toString();
    _selectedDateTime = event.date;
    _selectedOption = event.category;

    _isInitialized = true;
  }

  Widget modifyUI(dynamic event) {
    initializeControllers(event);
    return SingleChildScrollView(
      child: Column(
        children: [
          customTextField(controller: titleController, hint: "Event Title"),
          const SizedBox(height: 16),
          customTextField(
            controller: descriptionController,
            hint: "Event Description",
            maxLines: 6,
          ),
          const SizedBox(height: 16),
          customTextField(
            controller: locationController,
            hint: "Event Location",
          ),
          const SizedBox(height: 16),
          customTextField(
            controller: priceController,
            hint: "Price",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          dateMenuUi(),
          const SizedBox(height: 20),
          customButton(
            text: _isLoading ? "Updating..." : "Update Event",
            icon: _isLoading ? null : Icons.send,
            isLoading: _isLoading,
            onPressed: () {
              if (_isLoading) return;

              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  locationController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  _selectedDateTime == null ||
                  _selectedOption == null) {
                snackMessage(
                  context,
                  "Please fill all fields and select an image.",
                  Colors.red,
                );
                return;
              } else {
                updateEvent(event.eventId);
              }
            },
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Detail'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
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

          return isEditing ? modifyUI(event) : OwnEventUi(event);
        },
      ),
    );
  }

  Widget deleteButton(dynamic eventId) {
    return ElevatedButton(
      onPressed: () async {
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Confirm Delete'),
                content: Text('Are you sure you want to delete this event?'),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: Text('Yes, Delete'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
        );

        if (shouldDelete == true) {
          try {
            await FirebaseFirestore.instance
                .collection('events')
                .doc(eventId)
                .delete();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Event deleted')));
            int count = 0;
            Navigator.of(context).popUntil((route) {
              return count++ == 2; // Pops two screens
            });
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error deleting event: $e')));
          }
        }
      },
      child: Text('Delete Event'),
    );
  }

  Widget safeTopUi(event) {
    try {
      return topUi(event);
    } catch (e) {
      return Text("topUi error: $e");
    }
  }

  Widget safedescription(event) {
    try {
      return description(event);
    } catch (e) {
      return Text("topUi error: $e");
    }
  }

  Widget safebutton(event) {
    try {
      return deleteButton(event);
    } catch (e) {
      return Text("topUi error: $e");
    }
  }

  Widget OwnEventUi(dynamic event) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    safeTopUi(event),

                    const SizedBox(height: 24),
                    safedescription(event),
                    safebutton(event.eventId),
                  ],
                ),
              ),
            ],
          ),
        ),
        _users.isEmpty
            ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Center(
                  child: Text("No Users found", style: TextStyle(fontSize: 18)),
                ),
              ),
            )
            :
            // : SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 40.0),
            //     child: Center(
            //       child: Text(
            //         "No events found",
            //         style: TextStyle(fontSize: 18),
            //       ),
            //     ),
            //   ),
            // ),
            SliverList(delegate: SliverChildListDelegate(cardUi())),
      ],
    );
  }
}
