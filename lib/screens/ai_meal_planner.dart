import 'package:flutter/material.dart';
import '../widgets/feature_template.dart';

class AIFeaturePage extends StatelessWidget {
  const AIFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureTemplate(
      title: "AI Meal Planner",
      content: """
🍳 **Today's Personalized Meal Plan**

🥣 Breakfast: Oatmeal with banana and almonds  
🥗 Lunch: Grilled chicken salad with olive oil  
🍲 Dinner: Salmon with quinoa and steamed vegetables  
🍎 Snacks: Greek yogurt and apple slices  

💡 Caloric Goal: 2000 kcal  
🧮 AI Suggestion: Slightly reduce carbs for better protein balance.
""",
    );
  }
}
