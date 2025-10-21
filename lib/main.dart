import 'package:flutter/material.dart';
import 'screens/main_page.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Meal Planner (Frontend)',
      theme: AppTheme.lightTheme,

      home: const MainPage(), // 👈 Start with MainPage now
    );
  }
}
