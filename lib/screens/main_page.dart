import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'ai_meal_planner.dart';
import 'real_time_adjustments.dart';
import 'recipe_generator.dart';
import 'nutrient_alerts.dart';
import 'calorie_tracker.dart';
import 'ai_learning_engine.dart';
import '../theme.dart'; // 🌿 Import your organic theme

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {'title': 'AI Meal Planner', 'page': const AIFeaturePage()},
      {'title': 'Real-Time Adjustments', 'page': const AdjustmentPage()},
      {'title': 'Smart Recipe Generator', 'page': const RecipePage()},
      {'title': 'Nutrient Deficiency Alerts', 'page': const NutrientPage()},
      {'title': 'Calorie & Macro Tracker', 'page': const CaloriePage()},
      {'title': 'AI Learning Engine', 'page': const AILearningPage()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Meal Planner Dashboard"),
        backgroundColor: AppTheme.primary, // 🌿 Organic appbar
        foregroundColor: AppTheme.textLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            tooltip: "Login",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: "Sign Up",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient:
              AppTheme.organicGradient, // 🌿 Replaces purple-blue gradient
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "Explore AI Meal Planner Features:",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textLight,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 🌿 Feature cards
            ...features.map(
              (f) => Card(
                color: AppTheme.card,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: ListTile(
                  title: Text(
                    f['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: AppTheme.accent,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => f['page'] as Widget,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 🌿 Note section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Text(
                "Note: This is a frontend demo. You can explore all features without logging in. Authentication (Login/Signup) will be linked to Firebase later.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
