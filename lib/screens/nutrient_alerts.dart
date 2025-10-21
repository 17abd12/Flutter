import 'package:flutter/material.dart';
import '../widgets/feature_template.dart';

class NutrientPage extends StatelessWidget {
  const NutrientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureTemplate(
      title: "Nutrient Deficiency Alerts",
      content: """
⚠️ **Nutrient Report**

🧠 Vitamin D: Low  
💪 Protein: Optimal  
❤️ Iron: Slightly Low  
🔥 Calories: Balanced  

💡 *Recommendation:* Add eggs or fortified milk to your breakfast to fix Vitamin D deficiency.
""",
    );
  }
}
