import 'package:flutter/material.dart';
import '../widgets/feature_template.dart';

class AdjustmentPage extends StatelessWidget {
  const AdjustmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureTemplate(
      title: "Real-Time Adjustments",
      content: """
⚙️ **AI Meal Adjustment Example**

You skipped breakfast ☕  
➡ AI redistributed calories to lunch and dinner.  

🥗 Updated Lunch: Grilled chicken wrap + smoothie  
🍲 Updated Dinner: Rice bowl with tofu & vegetables  

🏃 Activity tracked: 20 min walk  
🔄 Calorie balance automatically adjusted by +150 kcal.
""",
    );
  }
}
