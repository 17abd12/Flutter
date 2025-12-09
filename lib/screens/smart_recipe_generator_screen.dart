import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../services/recipe_generation_state.dart';

class SmartRecipeGeneratorScreen extends StatefulWidget {
  const SmartRecipeGeneratorScreen({super.key});

  @override
  State<SmartRecipeGeneratorScreen> createState() =>
      _SmartRecipeGeneratorScreenState();
}

class _SmartRecipeGeneratorScreenState
    extends State<SmartRecipeGeneratorScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final RecipeGenerationState _generationState = RecipeGenerationState();
  
  final TextEditingController _ingredientsController = TextEditingController();
  String _selectedCuisine = 'Italian';
  String _selectedDifficulty = 'Medium';
  String _selectedMealType = 'Dinner';
  String _selectedMealPreference = 'Balanced';
  bool _generatedRecipe = false;
  
  Map<String, dynamic>? _generatedRecipeData;

  final List<String> _cuisines = [
    'Italian',
    'Indian',
    'Chinese',
    'Mexican',
    'Mediterranean',
    'American',
    'Thai',
    'Japanese',
  ];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];
  final List<String> _mealPreferences = [
    'Balanced',
    'High-Protein',
    'Low-Carb',
    'Vegetarian',
    'Vegan',
  ];

  @override
  void initState() {
    super.initState();
    // Listen to generation state changes
    _generationState.addListener(_onGenerationStateChanged);
    
    // Check if there's a completed recipe from previous generation
    if (_generationState.lastGeneratedRecipe != null) {
      setState(() {
        _generatedRecipeData = _generationState.lastGeneratedRecipe;
        _generatedRecipe = true;
      });
    }
  }

  void _onGenerationStateChanged() {
    if (mounted) {
      setState(() {
        // If generation just completed, update UI
        if (!_generationState.isGenerating && _generationState.lastGeneratedRecipe != null) {
          _generatedRecipeData = _generationState.lastGeneratedRecipe;
          _generatedRecipe = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _generationState.removeListener(_onGenerationStateChanged);
    _ingredientsController.dispose();
    super.dispose();
  }

  Future<void> _generateRecipe() async {
    if (_ingredientsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one ingredient'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to generate recipes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    
    setState(() {
      _generationState.startGeneration();
      _generatedRecipe = false;
    });

    try {
      // Get user profile
      final userProfile = await _firestoreService.getUserProfile(user.uid);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // Get today's meals and exercises
      final today = DateTime.now();
      final mealsToday = await _firestoreService.getMealsForDate(user.uid, today);
      final exercisesToday = await _firestoreService.getTodayExercises(user.uid);
      
      final caloriesIntakeToday = mealsToday.fold<int>(
        0, 
        (sum, meal) => sum + (meal['calories'] as int? ?? 0)
      );
      final caloriesBurntToday = exercisesToday.fold<int>(
        0, 
        (sum, ex) => sum + (ex['caloriesBurned'] as int? ?? 0)
      );

      // Parse ingredients
      final ingredientsList = _ingredientsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Use selected meal preference
      String mealPreference = _selectedMealPreference;

      print('🤖 Generating smart recipe with:');
      print('   Ingredients: $ingredientsList');
      print('   Cuisine: $_selectedCuisine');
      print('   Meal Type: $_selectedMealType');
      print('   Difficulty: $_selectedDifficulty');
      print('   Preference: $mealPreference');

      // Call backend API
      final response = await _apiService.generateSmartRecipe(
        userId: user.uid,
        ingredients: ingredientsList,
        cuisineType: _selectedCuisine,
        mealType: _selectedMealType.toLowerCase(),
        difficulty: _selectedDifficulty.toLowerCase(),
        mealPreference: mealPreference.toLowerCase(),
        calorieGoal: userProfile.calorieIntakeGoal,
        caloriesIntakeToday: caloriesIntakeToday,
        caloriesBurntToday: caloriesBurntToday,
        currentWeight: userProfile.currentWeight,
        targetWeight: userProfile.targetWeight,
        height: userProfile.height,
        age: userProfile.age,
        gender: userProfile.gender.toLowerCase(),
        goal: userProfile.goal,
        activityLevel: userProfile.activityLevel,
      );

      if (!mounted) return;
      
      setState(() {
        _generatedRecipeData = response;
        _generatedRecipe = true;
      });
      
      _generationState.completeGeneration(response);

      print('✅ Recipe generated successfully!');
      
      // Save generated recipe to Firestore
      try {
        // Extract recipe data from the response
        final recipeData = response['recipe'] ?? response;
        await _firestoreService.saveGeneratedRecipe(
          uid: user.uid,
          recipeName: recipeData['name'] ?? 'Unnamed Recipe',
          recipeData: recipeData,
        );
        print('✅ Recipe saved to Firestore');
      } catch (saveError) {
        print('⚠️ Failed to save recipe to Firestore: $saveError');
        // Don't show error to user, recipe is still generated
      }

    } catch (e) {
      print('❌ Error generating recipe: $e');
      _generationState.failGeneration(e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate recipe: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.boldGradient),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        title: const Text(
          'Smart Recipe Generator',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear and start new recipe',
            onPressed: () {
              setState(() {
                _ingredientsController.clear();
                _selectedCuisine = 'Italian';
                _selectedDifficulty = 'Medium';
                _selectedMealType = 'Dinner';
                _selectedMealPreference = 'Balanced';
                _generatedRecipe = false;
                _generatedRecipeData = null;
              });
              _generationState.clearLastRecipe();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.boldGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI-Powered Recipe',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tell us what you have!',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ingredients Input
          const Text(
            'What ingredients do you have?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _ingredientsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'e.g., chicken, tomatoes, onions, garlic, olive oil...',
                hintStyle: TextStyle(
                  color: AppTheme.textDark.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
            ),
          ),
          const SizedBox(height: 24),

          // Preferences Section
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),

          // Cuisine Selection
          _buildDropdownCard(
            'Cuisine Type',
            _selectedCuisine,
            _cuisines,
            (value) => setState(() => _selectedCuisine = value!),
            Icons.restaurant,
          ),
          const SizedBox(height: 12),

          // Meal Type Selection
          _buildDropdownCard(
            'Meal Type',
            _selectedMealType,
            _mealTypes,
            (value) => setState(() => _selectedMealType = value!),
            Icons.fastfood,
          ),
          const SizedBox(height: 12),

          // Difficulty Selection
          _buildDropdownCard(
            'Difficulty',
            _selectedDifficulty,
            _difficulties,
            (value) => setState(() => _selectedDifficulty = value!),
            Icons.bar_chart,
          ),
          const SizedBox(height: 12),

          // Meal Preference Selection
          _buildDropdownCard(
            'Meal Preference',
            _selectedMealPreference,
            _mealPreferences,
            (value) => setState(() => _selectedMealPreference = value!),
            Icons.restaurant_menu,
          ),
          const SizedBox(height: 24),

          // Generate Button or Loading Indicator
          if (_generationState.isGenerating)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Generating your personalized recipe...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: _generateRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Generate Recipe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Generated Recipe Display
          if (_generatedRecipe) _buildGeneratedRecipe(),
        ],
      ),
    );
  }

  Widget _buildDropdownCard(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            alignment: AlignmentDirectional.centerEnd,
            isDense: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedRecipe() {
    if (_generatedRecipeData == null) {
      return const SizedBox.shrink();
    }

    final recipe = _generatedRecipeData!['recipe'] as Map<String, dynamic>;
    final analysis = _generatedRecipeData!['analysis'] as Map<String, dynamic>;
    final source = _generatedRecipeData!['source'] as String;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.organicGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI-Generated Recipe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      source == 'rag_enhanced'
                          ? 'From our recipe database'
                          : 'Custom generated for you',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recipe Title
          Text(
            recipe['name'] ?? 'Generated Recipe',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),

          // Recipe Description
          if (recipe['description'] != null)
            Text(
              recipe['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          const SizedBox(height: 16),

          // Recipe Stats
          Row(
            children: [
              if (recipe['prep_time'] != null)
                _buildStatBadge(
                    Icons.access_time, recipe['prep_time'], Colors.blue),
              if (recipe['prep_time'] != null) const SizedBox(width: 8),
              if (recipe['cook_time'] != null)
                _buildStatBadge(Icons.timer, recipe['cook_time'], Colors.green),
              if (recipe['cook_time'] != null) const SizedBox(width: 8),
              if (recipe['nutrition']?['calories'] != null)
                _buildStatBadge(
                  Icons.local_fire_department,
                  '${recipe['nutrition']['calories']} cal',
                  Colors.orange,
                ),
              if (recipe['nutrition']?['calories'] != null)
                const SizedBox(width: 8),
              _buildStatBadge(
                Icons.bar_chart,
                recipe['difficulty'] ?? 'Medium',
                AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nutrition Info
          if (recipe['nutrition'] != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nutrition (per serving)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionItem(
                        'Protein',
                        '${recipe['nutrition']['protein'] ?? 0}g',
                      ),
                      _buildNutritionItem(
                        'Carbs',
                        '${recipe['nutrition']['carbs'] ?? 0}g',
                      ),
                      _buildNutritionItem(
                        'Fats',
                        '${recipe['nutrition']['fats'] ?? 0}g',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Analysis Section
          if (analysis.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: analysis['fits_goal'] == true
                    ? Colors.green.withValues(alpha: 0.05)
                    : Colors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: analysis['fits_goal'] == true
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        analysis['fits_goal'] == true
                            ? Icons.check_circle
                            : Icons.info,
                        color: analysis['fits_goal'] == true
                            ? Colors.green
                            : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Personalized Analysis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (analysis['recommendation'] != null)
                    Text(
                      analysis['recommendation'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  if (analysis['remaining_calories_today'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Remaining calories today: ${analysis['remaining_calories_today']} cal',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  if (analysis['protein_percentage'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Protein: ${analysis['protein_percentage']}% of calories',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Ingredients List
          if (recipe['ingredients'] != null &&
              (recipe['ingredients'] as List).isNotEmpty) ...[
            const Text(
              'Ingredients:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ...(recipe['ingredients'] as List).map((ingredient) {
              return _buildIngredientItem(ingredient.toString());
            }),
            const SizedBox(height: 20),
          ],

          // Instructions
          if (recipe['instructions'] != null &&
              (recipe['instructions'] as List).isNotEmpty) ...[
            const Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ...(recipe['instructions'] as List).asMap().entries.map((entry) {
              return _buildInstructionItem(entry.key + 1, entry.value.toString());
            }),
            const SizedBox(height: 20),
          ],

          // Tips Section
          if (recipe['tips'] != null &&
              (recipe['tips'] as List).isNotEmpty) ...[
            const Text(
              'Pro Tips:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ...(recipe['tips'] as List).map((tip) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 18, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textDark.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(int step, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textDark.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
