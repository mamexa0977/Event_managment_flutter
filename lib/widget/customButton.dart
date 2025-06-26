import 'package:flutter/material.dart';

Widget customButton({
  required String text,
  required VoidCallback onPressed,
  IconData? icon,
  Color color = const Color(0xFF6759FF),
  bool isLoading = false,
  double height = 55,
  double borderRadius = 14,
  Color textColor = Colors.white,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: [color.withOpacity(0.95), color],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          offset: const Offset(0, 6),
          blurRadius: 12,
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isLoading ? null : onPressed,
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        child: Center(
          child:
              isLoading
                  ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) Icon(icon, color: textColor, size: 20),
                      if (icon != null) const SizedBox(width: 8),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    ),
  );
}
