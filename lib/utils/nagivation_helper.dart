import 'package:flutter/material.dart';

// Push to a new screen
void navigateToScreen(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}

// Push and remove the current screen (replace)
void navigateAndReplace(BuildContext context, Widget screen) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}

// Pop the current screen (go back)
void goBack(BuildContext context) {
  Navigator.pop(context);
}



