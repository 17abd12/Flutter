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
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.boldGradient),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        title: Text(
          recipe['name'],
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
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
          _buildRecipeImage(recipe, isSmallScreen),

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
                            '${_getNutritionValue(recipe, 'protein')}g',
                            isSmallScreen,
                          ),
                          _buildNutritionItem(
                            'Carbs', 
                            '${_getNutritionValue(recipe, 'carbs')}g', 
                            isSmallScreen
                          ),
                          _buildNutritionItem(
                            'Fats', 
                            '${_getNutritionValue(recipe, 'fats')}g', 
                            isSmallScreen
                          ),
                          _buildNutritionItem(
                            'Fiber', 
                            '${_getNutritionValue(recipe, 'fiber')}g', 
                            isSmallScreen
                          ),
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
                    children: _buildIngredientsList(recipe, isSmallScreen),
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
                    children: _buildInstructionsList(recipe, isSmallScreen),
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

  Widget _buildRecipeImage(Map<String, dynamic> recipe, bool isSmallScreen) {
    final imageUrl = recipe['image_url'];
    final hasValidUrl = imageUrl != null && 
                        imageUrl.toString().isNotEmpty && 
                        imageUrl.toString() != 'N/A' &&
                        (imageUrl.toString().startsWith('http://') || 
                         imageUrl.toString().startsWith('https://'));
    
    String getProxiedUrl(String url) {
      if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
        return 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}';
      }
      return url;
    }
    
    final displayUrl = hasValidUrl ? getProxiedUrl(imageUrl) : '';
    
    return ClipRRect(
      child: hasValidUrl
          ? Image.network(
              displayUrl,
              height: isSmallScreen ? 200 : 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
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
                      recipe['image'] ?? '🍽️',
                      style: TextStyle(fontSize: isSmallScreen ? 80 : 100),
                    ),
                  ),
                );
              },
            )
          : Container(
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
                  recipe['image'] ?? '🍽️',
                  style: TextStyle(fontSize: isSmallScreen ? 80 : 100),
                ),
              ),
            ),
    );
  }

  dynamic _getNutritionValue(Map<String, dynamic> recipe, String nutrient) {
    // Check if nutritions field exists and is a map
    if (recipe['nutritions'] != null && recipe['nutritions'] is Map) {
      final nutritions = recipe['nutritions'] as Map<String, dynamic>;
      if (nutritions[nutrient] != null) {
        return nutritions[nutrient];
      }
    }
    
    // Fallback to direct recipe field
    if (recipe[nutrient] != null) {
      return recipe[nutrient];
    }
    
    // Default values
    return 0;
  }

  List<Widget> _buildIngredientsList(Map<String, dynamic> recipe, bool isSmallScreen) {
    // Debug: Print recipe keys and ingredients value
    print('🔍 Recipe keys: ${recipe.keys.toList()}');
    print('🔍 Ingredients type: ${recipe['ingredients']?.runtimeType}');
    print('🔍 Ingredients value: ${recipe['ingredients']}');
    
    // Check if ingredients field exists
    if (recipe['ingredients'] != null && recipe['ingredients'] is List) {
      final ingredients = recipe['ingredients'] as List;
      print('✅ Found ${ingredients.length} ingredients');
      if (ingredients.isNotEmpty) {
        return ingredients.map((ingredient) {
          return _buildIngredientItem(ingredient.toString(), isSmallScreen);
        }).toList();
      }
    }
    
    print('❌ No ingredients found in recipe data');
    // Fallback to default message
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Ingredients information not available',
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 15,
            color: AppTheme.textDark.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildInstructionsList(Map<String, dynamic> recipe, bool isSmallScreen) {
    // Check if instructions field exists
    if (recipe['instructions'] != null && recipe['instructions'] is List) {
      final instructions = recipe['instructions'] as List;
      if (instructions.isNotEmpty) {
        return instructions.asMap().entries.map((entry) {
          return _buildInstructionStep(
            entry.key + 1, 
            entry.value.toString(), 
            isSmallScreen
          );
        }).toList();
      }
    }
    
    // Fallback to default message
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Cooking instructions not available',
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 15,
            color: AppTheme.textDark.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    ];
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
