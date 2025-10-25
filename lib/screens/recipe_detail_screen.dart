import 'package:flutter/material.dart';
import '../theme.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: Text(
          recipe['name'],
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to favorites!'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share recipe'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Recipe Image Header
          Container(
            height: isSmallScreen ? 200 : 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.4),
                  AppTheme.secondary.withOpacity(0.4),
                ],
              ),
            ),
            child: Center(
              child: Text(
                recipe['image'],
                style: TextStyle(fontSize: isSmallScreen ? 80 : 100),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Stats
                Row(
                  children: [
                    _buildStatChip(
                      Icons.local_fire_department,
                      '${recipe['calories']} cal',
                      Colors.orange,
                      isSmallScreen,
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    _buildStatChip(
                      Icons.access_time,
                      recipe['time'],
                      AppTheme.primary,
                      isSmallScreen,
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    _buildStatChip(
                      Icons.restaurant,
                      recipe['difficulty'],
                      Colors.blue,
                      isSmallScreen,
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),

                // Nutrition Info
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrition Per Serving',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNutritionItem(
                            'Protein',
                            '${recipe['protein']}g',
                            isSmallScreen,
                          ),
                          _buildNutritionItem('Carbs', '45g', isSmallScreen),
                          _buildNutritionItem('Fats', '12g', isSmallScreen),
                          _buildNutritionItem('Fiber', '8g', isSmallScreen),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),

                // Ingredients Section
                Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIngredientItem(
                        '2 cups fresh spinach',
                        isSmallScreen,
                      ),
                      _buildIngredientItem(
                        '1 large chicken breast (200g)',
                        isSmallScreen,
                      ),
                      _buildIngredientItem('1/2 cup quinoa', isSmallScreen),
                      _buildIngredientItem('1 tbsp olive oil', isSmallScreen),
                      _buildIngredientItem(
                        '2 cloves garlic, minced',
                        isSmallScreen,
                      ),
                      _buildIngredientItem('1 tsp salt', isSmallScreen),
                      _buildIngredientItem(
                        '1/2 tsp black pepper',
                        isSmallScreen,
                      ),
                      _buildIngredientItem(
                        '1/4 cup cherry tomatoes',
                        isSmallScreen,
                      ),
                      _buildIngredientItem('1 tbsp lemon juice', isSmallScreen),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),

                // Instructions Section
                Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstructionStep(
                        1,
                        'Rinse the quinoa under cold water and cook according to package instructions. Set aside.',
                        isSmallScreen,
                      ),
                      _buildInstructionStep(
                        2,
                        'Season the chicken breast with salt and pepper on both sides.',
                        isSmallScreen,
                      ),
                      _buildInstructionStep(
                        3,
                        'Heat olive oil in a large skillet over medium-high heat.',
                        isSmallScreen,
                      ),
                      _buildInstructionStep(
                        4,
                        'Add the chicken breast to the skillet and cook for 6-7 minutes on each side until golden brown and cooked through. Remove and let it rest.',
                        isSmallScreen,
                      ),
                      _buildInstructionStep(
                        5,
                        'In the same skillet, add minced garlic and sauté for 30 seconds until fragrant.',
                        isSmallScreen,
                      ),
                      _buildInstructionStep(
                        6,
                        'Add the fresh spinach and cherry tomatoes. Cook for 2-3 minutes until spinach is wilted.',
                        isSmallScreen,
                      ),
                      _buildInstructionStep(
                        7,
                        'Slice the chicken breast into strips and add it back to the skillet.',
                        isSmallScreen,
                      ),
                      _buildInstructionStep(
                        8,
                        'Add the cooked quinoa to the skillet and mix everything together.',
                        isSmallScreen,
                      ),
                      _buildInstructionStep(
                        9,
                        'Drizzle with lemon juice and toss to combine. Adjust seasoning if needed.',
                        isSmallScreen,
                      ),
                      _buildInstructionStep(
                        10,
                        'Serve hot and enjoy your healthy meal!',
                        isSmallScreen,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recipe saved!'),
                              backgroundColor: AppTheme.primary,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.bookmark_outline,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        label: Text(
                          'Save',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 10 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to meal plan!'),
                              backgroundColor: AppTheme.primary,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.add_circle,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        label: Text(
                          'Add to Plan',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 10 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String label,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallScreen ? 12 : 14, color: color),
          SizedBox(width: isSmallScreen ? 3 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, bool isSmallScreen) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: AppTheme.textDark.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(String text, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: isSmallScreen ? 5 : 6),
            width: isSmallScreen ? 7 : 8,
            height: isSmallScreen ? 7 : 8,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 15,
                color: AppTheme.textDark.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int step, String text, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 14 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmallScreen ? 28 : 32,
            height: isSmallScreen ? 28 : 32,
            decoration: BoxDecoration(
              gradient: AppTheme.organicGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: isSmallScreen ? 4 : 5),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15,
                  color: AppTheme.textDark.withOpacity(0.85),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
