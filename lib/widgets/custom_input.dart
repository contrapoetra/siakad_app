import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final bool enabled;
  final bool readOnly; // New parameter
  final VoidCallback? onTap; // New parameter

  const CustomInput({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false, // Default to false
    this.onTap, // Optional onTap callback
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        enabled: enabled,
        readOnly: readOnly, // Pass to TextFormField
        onTap: onTap, // Pass to TextFormField
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }
}
