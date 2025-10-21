import 'package:flutter/material.dart';
import '../widgets/feature_template.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureTemplate(
      title: "Smart Recipe Generator",
      content: """
🥕 **Available Ingredients:**  
- Tomato  
- Cheese  
- Bread  
- Basil  

🍞 **Generated Recipe:**  
**Caprese Toast**
- Toast bread slices  
- Add tomato, cheese, and basil leaves  
- Drizzle with olive oil and bake for 5 mins  

🥬 *Substitutions:*  
- Cheese → Tofu (for lactose-free users)  
- Bread → Whole grain (for low-carb diet)
""",
    );
  }
}
