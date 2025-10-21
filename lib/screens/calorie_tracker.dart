import 'package:flutter/material.dart';
import '../widgets/feature_template.dart';

class CaloriePage extends StatelessWidget {
  const CaloriePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureTemplate(
      title: "Calorie & Macro Tracker",
      content: """
📊 **Today's Macro Breakdown**

Carbohydrates: 180g  
Protein: 90g  
Fats: 55g  
Calories: 1,950 kcal  

🔥 *Goal Progress:* 97% of daily calorie target  
💡 Suggestion: Increase protein by 10g to balance macros.
""",
    );
  }
}
