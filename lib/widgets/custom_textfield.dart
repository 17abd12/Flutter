import 'package:flutter/material.dart';
import '../theme.dart'; // 🌿 Import the theme file

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: Theme.of(context).textTheme.bodyLarge, // 🌿 use theme text
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textDark), // 🌿 organic text color
        prefixIcon: Icon(icon, color: AppTheme.primary), // 🌿 themed icon
        filled: true,
        fillColor: AppTheme.card, // 🌿 soft background for text field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
        ),
      ),
    );
  }
}
