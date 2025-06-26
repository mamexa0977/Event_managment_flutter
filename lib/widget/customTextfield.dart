import 'package:flutter/material.dart';

Widget customTextField({
  required String hint,
  required TextEditingController controller,
  bool isPassword = false,
  TextInputType keyboardType = TextInputType.text,
  IconData? prefixIcon,
    int maxLines = 1,
    Function(String)? onChanged,
      Function(String)? onSubmitted, 
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
      ],
    ),
    child: TextField(
       onChanged: onChanged,
       onSubmitted: onSubmitted,
        maxLines: maxLines,
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[600])
                : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    ),
  );
}
