import 'package:flutter/material.dart';
import '../widgets/feature_template.dart';

class AILearningPage extends StatelessWidget {
  const AILearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureTemplate(
      title: "AI Learning Engine",
      content: """
**User Pattern Analysis (Mock Data)**

✅ Prefers high-protein breakfasts  
✅ Avoids red meat on weekends  
✅ Often skips lunch when busy  
✅ Likes spicy Indian dishes  

*AI Insight:*  
Based on your past choices, we’ll recommend light evening meals and higher protein breakfast options.
""",
    );
  }
}
