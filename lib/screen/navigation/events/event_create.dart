import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_mng_sys/model/eventModel.dart';
import 'package:event_mng_sys/provider.dart';
import 'package:event_mng_sys/utils/snack_helper.dart';
import 'package:event_mng_sys/widget/customButton.dart';
import 'package:event_mng_sys/widget/customTextfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:event_mng_sys/services/event_service.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

class EventCreate extends StatefulWidget {
  const EventCreate({super.key});

  @override
  State<EventCreate> createState() => _EventCreateState();
}

class _EventCreateState extends State<EventCreate> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTime? _selectedDateTime;
  String? _selectedOption;

  final List<String> _options = [
    'Gaming',
    'Basketball',
    'Education',
    'Fitness',
    'Food',
  ];

  bool _isLoading = false;
  File? imageFile;
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

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  createEvent() {
    final EventCreateService service = EventCreateService();
    Event newEvent = Event(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      imageUrl: "", // You'll set this later after uploading the image
      createdBy:
          FirebaseAuth.instance.currentUser?.uid ??
          "", // You may handle this based on the user session
      createdAt: DateTime.now(),
      date: _selectedDateTime,
      category: _selectedOption, // Use Firebase server timestamp
    );
    service.createEvent(
      context,
      () => setState(() {
        _isLoading = true;
      }),
      () => setState(() {
        _isLoading = false;
      }),
      imageFile!,
      newEvent,
    );
  }

  Widget dateMenuUi() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.calendar_today, size: 20),
                label: Text(
                  _selectedDateTime == null
                      ? 'Pick Date & Time'
                      : 'Picked: ${DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime!)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  await pickImage();
                },
                child: Container(
                  width: 150, // set desired width
                  height: 150, // set desired height
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // rectangular with rounded corners
                    image:
                        imageFile != null
                            ? DecorationImage(
                              image: FileImage(imageFile!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      imageFile == null
                          ? const Center(
                            child: Icon(Icons.add_a_photo, size: 30),
                          )
                          : null,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: customTextField(
                controller: _titleController,
                hint: "Event Title",
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: customTextField(
                controller: _descriptionController,
                hint: "Event Description",
                maxLines: 6,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: customTextField(
                controller: _locationController,
                hint: "Event Location",
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: customTextField(
                controller: _priceController,
                hint: "Price",
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            dateMenuUi(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: customButton(
                text: _isLoading ? "Creating..." : "Create Event",
                icon: _isLoading ? null : Icons.send,
                isLoading: _isLoading,
                onPressed: () {
                  if (_isLoading) return;

                  if (_titleController.text.isEmpty ||
                      _descriptionController.text.isEmpty ||
                      _locationController.text.isEmpty ||
                      _priceController.text.isEmpty ||
                      imageFile == null ||
                      _selectedDateTime == null) {
                    snackMessage(
                      context,
                      "Please fill all fields and select an image.",
                      Colors.red,
                    );
                    return;
                  } else {
                    createEvent();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
