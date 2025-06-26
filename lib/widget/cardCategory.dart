import 'package:flutter/material.dart';

Widget cardCategory(IconData icon, String name, GestureTapCallback ontapp) {
  return GestureDetector(
    onTap: ontapp,
    child: Card(
      elevation: 6, // Increased elevation for a more prominent shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black.withOpacity(0.4), // Softer shadow
      child: Container(
        width: 80, // Small card size
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Color(0xFF7AC6D2),
              Color(0xffB5FCCD),
            ], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon, // Icon for the category
              color: Colors.white,
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              name, // Event name
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize:
                    14, // Slightly smaller font size for better proportion
              ),
              textAlign: TextAlign.center, // Ensures the text is centered
            ),
          ],
        ),
      ),
    ),
  );
}
