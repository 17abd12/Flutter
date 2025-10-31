import 'package:flutter/material.dart';
import '../theme.dart'; // 🌿 for colors and gradient

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final motivationController = TextEditingController();

  String goal = "Lose Weight";
  String activityLevel = "Moderate";
  String gender = "Male";
  String duration = "3 Months";

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
                    const SizedBox(height: 30),

                    // 🌿 Continue button
                    ElevatedButton(
                      onPressed: () {
                        // You could save this data to a database or send to next screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "🎯 Goal saved: $goal for $duration\nCurrent: ${weightController.text}kg → Target: ${targetWeightController.text}kg",
                            ),
                          ),
                        );
                      },
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
                      child: const Text("Save & Continue"),
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
}
