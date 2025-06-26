import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color? textColor;
  final Image? image;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.image,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            image ?? Container(),
            SizedBox(width: 17),
            Text(
              text,
              style: TextStyle(fontSize: 16, color: textColor ?? Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
