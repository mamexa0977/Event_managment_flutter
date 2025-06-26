// import 'package:flutter/material.dart';

// class CustomTextField extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final bool isPassword;
//   final TextInputType keyboardType;
//   final TextEditingController controller;

//   const CustomTextField({
//     super.key,
//     required this.label,
//     required this.icon,
//     this.isPassword = false,
//     this.keyboardType = TextInputType.text,
//     required this.controller,
//   });

//   @override
//   State<CustomTextField> createState() => _CustomTextFieldState();
// }

// class _CustomTextFieldState extends State<CustomTextField> {
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       validator:
//           (value) => value == null || value.isEmpty ? 'Required field' : null,
//       controller: widget.controller,
//       obscureText: widget.isPassword,
//       keyboardType: widget.keyboardType,
//       decoration: InputDecoration(
//         labelText: widget.label,
//         prefixIcon: Icon(widget.icon),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         suffixIcon:
//             widget.isPassword
//                 ? IconButton(
//                   icon: const Icon(Icons.visibility_off),
//                   onPressed: () {},
//                 )
//                 : null,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    required this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword; // only obscure if it's password
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator:
          (value) => value == null || value.isEmpty ? 'Required field' : null,
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null,
      ),
    );
  }
}
