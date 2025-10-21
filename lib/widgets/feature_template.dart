import 'package:flutter/material.dart';
import '../theme.dart'; // 🌿 Import your organic theme

class FeatureTemplate extends StatelessWidget {
  final String title;
  final String content;
  const FeatureTemplate({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primary, // 🌿 use theme color
        foregroundColor: AppTheme.textLight,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.organicGradient, // 🌿 use theme gradient
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: AppTheme.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ), // use global text style
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
