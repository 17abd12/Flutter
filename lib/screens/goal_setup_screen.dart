import 'package:flutter/material.dart';
import '../theme.dart'; // 🌿 for colors and gradient
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class GoalSetupScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  final int age;

  const GoalSetupScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.age,
  });

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final calorieIntakeGoalController = TextEditingController(text: '2000');
  final calorieBurnGoalController = TextEditingController(text: '300');
  final motivationController = TextEditingController();
  final mealPreferenceController = TextEditingController();

  String goal = "Lose Weight";
  String activityLevel = "Moderate";
  String gender = "Male";
  String duration = "3 Months";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.organicGradient, // 🌿 soft background
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: AppTheme.card,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Set Your Fitness Goals 💪",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textDark,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 🌿 Weight
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Current Weight (kg)",
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Height
                    TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Height (cm)",
                        prefixIcon: Icon(Icons.height),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Target Weight
                    TextField(
                      controller: targetWeightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Target Weight (kg)",
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Gender
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(
                        labelText: "Gender",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Male", child: Text("Male")),
                        DropdownMenuItem(
                          value: "Female",
                          child: Text("Female"),
                        ),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (val) => setState(() => gender = val!),
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Goal Type
                    DropdownButtonFormField<String>(
                      value: goal,
                      decoration: const InputDecoration(
                        labelText: "Main Goal",
                        prefixIcon: Icon(Icons.fitness_center),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Lose Weight",
                          child: Text("Lose Weight"),
                        ),
                        DropdownMenuItem(
                          value: "Build Muscle",
                          child: Text("Build Muscle"),
                        ),
                        DropdownMenuItem(
                          value: "Stay Fit",
                          child: Text("Stay Fit"),
                        ),
                      ],
                      onChanged: (val) => setState(() => goal = val!),
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Activity Level
                    DropdownButtonFormField<String>(
                      value: activityLevel,
                      decoration: const InputDecoration(
                        labelText: "Activity Level",
                        prefixIcon: Icon(Icons.run_circle),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Low",
                          child: Text("Low (Sedentary)"),
                        ),
                        DropdownMenuItem(
                          value: "Moderate",
                          child: Text("Moderate (3-4 days/week)"),
                        ),
                        DropdownMenuItem(
                          value: "High",
                          child: Text("High (Daily activity)"),
                        ),
                      ],
                      onChanged: (val) => setState(() => activityLevel = val!),
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Duration
                    DropdownButtonFormField<String>(
                      value: duration,
                      decoration: const InputDecoration(
                        labelText: "Goal Duration",
                        prefixIcon: Icon(Icons.timer),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "1 Month",
                          child: Text("1 Month"),
                        ),
                        DropdownMenuItem(
                          value: "3 Months",
                          child: Text("3 Months"),
                        ),
                        DropdownMenuItem(
                          value: "6 Months",
                          child: Text("6 Months"),
                        ),
                        DropdownMenuItem(
                          value: "1 Year",
                          child: Text("1 Year"),
                        ),
                      ],
                      onChanged: (val) => setState(() => duration = val!),
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Motivation text
                    TextField(
                      controller: motivationController,
                      decoration: const InputDecoration(
                        labelText: "What's your motivation?",
                        prefixIcon: Icon(Icons.favorite),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Meal Preference
                    TextField(
                      controller: mealPreferenceController,
                      decoration: const InputDecoration(
                        labelText: "Meal Preference (Optional)",
                        prefixIcon: Icon(Icons.restaurant_menu),
                        border: OutlineInputBorder(),
                        helperText: "e.g., Vegetarian, Vegan, Keto, Halal, etc.",
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Calorie Intake Goal
                    TextField(
                      controller: calorieIntakeGoalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Daily Calorie Intake Goal (kcal)",
                        prefixIcon: Icon(Icons.restaurant),
                        border: OutlineInputBorder(),
                        helperText: "Recommended: 1500-2500 kcal",
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🌿 Calorie Burn Goal
                    TextField(
                      controller: calorieBurnGoalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Daily Calorie Burn Goal (kcal)",
                        prefixIcon: Icon(Icons.local_fire_department),
                        border: OutlineInputBorder(),
                        helperText: "Recommended: 200-500 kcal",
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 🌿 Continue button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.textLight,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 25,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Save & Continue"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Handle signup and save user data to Firestore
  Future<void> _handleSignup() async {
    // Validate all fields
    if (weightController.text.isEmpty ||
        heightController.text.isEmpty ||
        targetWeightController.text.isEmpty ||
        calorieIntakeGoalController.text.isEmpty ||
        calorieBurnGoalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user (already authenticated from email verification)
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw 'User not authenticated. Please verify your email first.';
      }

      // Create user profile with goal information
      UserModel userModel = UserModel(
        uid: user.uid,
        email: widget.email,
        name: widget.name,
        age: widget.age,
        currentWeight: double.parse(weightController.text),
        targetWeight: double.parse(targetWeightController.text),
        height: double.parse(heightController.text),
        gender: gender,
        goal: goal,
        activityLevel: activityLevel,
        duration: duration,
        calorieIntakeGoal: int.parse(calorieIntakeGoalController.text),
        calorieBurnGoal: int.parse(calorieBurnGoalController.text),
        motivation: motivationController.text,
        mealPreference: mealPreferenceController.text.isEmpty 
            ? null 
            : mealPreferenceController.text,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await FirestoreService().saveUserProfile(userModel);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to home screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen(isLoggedIn: true)),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      print('Error saving profile: $e'); // Debug log
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
