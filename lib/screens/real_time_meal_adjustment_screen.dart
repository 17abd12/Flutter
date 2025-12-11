import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../widgets/favorite_button.dart';

class RealTimeMealAdjustmentScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  
  const RealTimeMealAdjustmentScreen({super.key, this.onDataChanged});

  @override
  State<RealTimeMealAdjustmentScreen> createState() =>
      _RealTimeMealAdjustmentScreenState();
}

class _RealTimeMealAdjustmentScreenState
    extends State<RealTimeMealAdjustmentScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _selectedOption = 0; // 0: Enter calories, 1: AI estimate from description
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _isAddingMeal = false; // Loading state for adding meal
  bool _isLoadingSuggestions = false;
  String? _deletingMealId; // Track which meal is being deleted
  int dailyGoal = 2000;
  int consumedCalories = 0;
  int caloriesBurned = 0;
  List<Map<String, dynamic>> todaysMeals = [];
  List<Map<String, dynamic>> _mealSuggestions = [];

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    final user = _authService.currentUser;
    setState(() {
      _isLoggedIn = user != null;
    });

    if (_isLoggedIn) {
      await _loadRealData();
    } else {
      setState(() {
        _isLoading = false;
        // Use default mock data when not logged in
        dailyGoal = 2000;
        consumedCalories = 0;
        todaysMeals = [];
      });
    }
  }

  Future<void> _loadRealData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final summary = await _firestoreService.getDashboardSummary(user.uid);
        if (mounted) {
          setState(() {
            dailyGoal = summary['calorieGoal'] ?? 2000;
            consumedCalories = summary['caloriesConsumed'] ?? 0;
            caloriesBurned = summary['caloriesBurned'] ?? 0;
            todaysMeals = (summary['todayMeals'] as List? ?? []).cast<Map<String, dynamic>>();
            _isLoading = false;
          });
          
          // Load AI suggestions after data is loaded
          await _loadMealSuggestions();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMealSuggestions() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final remainingCalories = dailyGoal - consumedCalories + caloriesBurned;
    if (remainingCalories <= 200) return; // Don't show suggestions if low calories

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      // Get user profile for preferences
      final userProfile = await _firestoreService.getUserProfile(user.uid);
      
      // Get recent meal names
      final recentMealNames = todaysMeals
          .map((meal) => meal['mealName'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      // Get top 5 latest favorite recipes
      final allFavorites = await _firestoreService.getUserFavoriteRecipes(user.uid);
      final top5Favorites = allFavorites.take(5).map((fav) => {
        'name': fav['name'] ?? 'Unknown',
        'cuisine': fav['cuisine'] ?? 'Unknown',
        'source': fav['source'] ?? 'unknown',
        'calories': fav['calories'] ?? 0,
      }).toList();

      print('🍽️ Sending ${top5Favorites.length} favorite recipes to meal suggestions API');

      final response = await _apiService.getMealSuggestions(
        userId: user.uid,
        remainingCalories: remainingCalories,
        mealPreference: userProfile?.mealPreference ?? 'balanced',
        goal: userProfile?.goal ?? 'maintain',
        recentMeals: recentMealNames,
        favoriteRecipes: top5Favorites,
      );

      if (mounted) {
        setState(() {
          _mealSuggestions = (response['suggestions'] as List)
              .map((s) => s as Map<String, dynamic>)
              .toList();
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      print('Error loading meal suggestions: $e');
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
          // Keep empty suggestions on error
        });
      }
    }
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addMeal() async {
    if (_isAddingMeal) return; // Prevent double submission
    
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add meals'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_mealNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter meal name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    int calories;

    if (_selectedOption == 0) {
      // Manual calorie entry
      if (_caloriesController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter calories'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final parsedCalories = int.tryParse(_caloriesController.text);
      if (parsedCalories == null || parsedCalories <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid calorie amount'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      calories = parsedCalories;
    } else {
      // AI estimation from description via backend API
      if (_descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter meal description'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      try {
        final user = _authService.currentUser;
        if (user == null) {
          throw Exception('User not logged in');
        }

        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text('AI analyzing your meal description...'),
                ],
              ),
              backgroundColor: AppTheme.primary,
              duration: Duration(seconds: 30),
            ),
          );
        }

        // Fetch user profile for API request
        final userProfile = await _firestoreService.getUserProfile(user.uid);
        if (userProfile == null) {
          throw Exception('User profile not found');
        }

        // Calculate calories burned today
        final exercisesToday = await _firestoreService.getTodayExercises(user.uid);
        final caloriesBurntToday = exercisesToday.fold<int>(
          0, 
          (sum, ex) => sum + (ex['caloriesBurned'] as int? ?? 0)
        );

        // Call backend API for meal analysis
        final ApiService apiService = ApiService();
        final response = await apiService.analyzeMealDescription(
          userId: user.uid,
          mealDescription: _descriptionController.text,
          mealTime: 'lunch', // Default or detect from time of day
          calorieGoal: userProfile.calorieIntakeGoal,
          caloriesIntakeToday: consumedCalories,
          caloriesBurntToday: caloriesBurntToday,
          currentWeight: userProfile.currentWeight,
          targetWeight: userProfile.targetWeight,
          goal: userProfile.goal,
        );

        // Extract total calories from response (backend returns meal_analysis not analysis)
        final analysisData = response['meal_analysis'];
        calories = analysisData['estimated_calories'] ?? 200;
        
        // Extract meal items for detailed view (backend returns breakdown list with 'item' not 'item_name')
        final items = response['breakdown'] as List<dynamic>? ?? [];
        final itemsText = items.map((item) => 
          '${item['item']}: ${item['calories']} cal'
        ).join(', ');

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'AI estimated $calories calories${itemsText.isNotEmpty ? "\\n$itemsText" : ""}',
              ),
              backgroundColor: AppTheme.secondary,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        print('❌ Error analyzing meal with AI: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI analysis failed: ${e.toString()}. Using fallback estimation.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        // Fallback to simple estimation
        calories = _estimateCaloriesFromDescription(_descriptionController.text);
      }
    }

    // Set loading state
    setState(() => _isAddingMeal = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        // 🚀 OPTIMIZATION: Add meal to local list IMMEDIATELY (no reload needed)
        final now = DateTime.now();
        final newMeal = {
          'id': 'temp_${now.millisecondsSinceEpoch}', // Temp ID
          'mealName': _mealNameController.text,
          'calories': calories,
          'timestamp': now.toIso8601String(),
          'mealType': 'Custom',
          'isSyncing': true, // Mark as syncing with Firestore
        };

        // Add to top of list for instant feedback
        setState(() {
          todaysMeals.insert(0, newMeal);
          consumedCalories += calories;
        });

        // Clear input fields immediately
        _mealNameController.clear();
        _caloriesController.clear();
        _descriptionController.clear();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Meal added! Syncing with Firestore...'),
              backgroundColor: AppTheme.secondary,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Save to Firestore in BACKGROUND (non-blocking)
        _firestoreService.logMeal(
          uid: user.uid,
          mealName: newMeal['mealName'] as String,
          calories: calories,
          mealType: 'Custom',
        ).then((_) async {
          // Success: Update temp meal with real Firestore ID
          if (mounted) {
            setState(() {
              final index = todaysMeals.indexWhere((m) => m['id'] == newMeal['id']);
              if (index != -1) {
                todaysMeals[index]['isSyncing'] = false;
              }
            });
            widget.onDataChanged?.call();
            
            // Clear suggestions cache and reload with new meal context
            await _apiService.clearMealSuggestionsCache(userId: user.uid);
            await _loadMealSuggestions();
          }
        }).catchError((e) {
          // Error: Remove from local list and show error
          if (mounted) {
            setState(() {
              todaysMeals.removeWhere((m) => m['id'] == newMeal['id']);
              consumedCalories -= calories;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save meal: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });

        // Set loading state to false (no need to wait for Firestore)
        if (mounted) {
          setState(() => _isAddingMeal = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAddingMeal = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding meal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Mock AI estimation - Replace with actual AI API call
  int _estimateCaloriesFromDescription(String description) {
    // Simple mock logic based on keywords
    final lowerDesc = description.toLowerCase();
    int baseCalories = 200;

    // Portion size modifiers
    if (lowerDesc.contains('small') || lowerDesc.contains('little')) {
      baseCalories = 150;
    } else if (lowerDesc.contains('large') || lowerDesc.contains('big')) {
      baseCalories = 400;
    } else if (lowerDesc.contains('two') || lowerDesc.contains('2')) {
      baseCalories = 500;
    } else if (lowerDesc.contains('three') || lowerDesc.contains('3')) {
      baseCalories = 700;
    }

    // Food type modifiers
    if (lowerDesc.contains('rice') ||
        lowerDesc.contains('pasta') ||
        lowerDesc.contains('bread')) {
      baseCalories += 150;
    }
    if (lowerDesc.contains('ice cream') ||
        lowerDesc.contains('cake') ||
        lowerDesc.contains('dessert')) {
      baseCalories += 200;
    }
    if (lowerDesc.contains('salad') || lowerDesc.contains('vegetables')) {
      baseCalories = (baseCalories * 0.6).round();
    }
    if (lowerDesc.contains('fried') || lowerDesc.contains('oil')) {
      baseCalories += 150;
    }

    return baseCalories;
  }

  Future<void> _removeMeal(int index) async {
    if (!_isLoggedIn) return;

    final meal = todaysMeals[index];
    final mealId = meal['id'];
    
    if (mealId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete this meal'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prevent double deletion
    if (_deletingMealId == mealId) return;

    setState(() => _deletingMealId = mealId);

    try {
      await _firestoreService.deleteMeal(mealId);
      await _loadRealData(); // Reload data
      
      if (mounted) {
        setState(() => _deletingMealId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal deleted'),
            backgroundColor: AppTheme.primary,
          ),
        );
        // Notify parent to refresh other screens
        widget.onDataChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deletingMealId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting meal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingCalories = dailyGoal - consumedCalories + caloriesBurned;
    final progress = consumedCalories / dailyGoal;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppTheme.boldGradient),
          ),
          elevation: 4,
          title: const Text('Real-Time Adjustments'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.boldGradient),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        title: const Text(
          'Real-Time Adjustments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show meal history
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
                        Icons.timeline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s Tracking',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'What did you eat today?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
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

          // Calorie Summary Card
          Container(
            padding: const EdgeInsets.all(24),
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
              children: [
                const Text(
                  'Calories Remaining',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Circular Progress
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 16,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            remainingCalories >= 0
                                ? AppTheme.primary
                                : Colors.red,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            remainingCalories.abs().toString(),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: remainingCalories >= 0
                                  ? AppTheme.textDark
                                  : Colors.red,
                            ),
                          ),
                          Text(
                            remainingCalories >= 0 ? 'Remaining' : 'Over',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textDark.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'Goal',
                      dailyGoal.toString(),
                      AppTheme.primary,
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _buildStatColumn(
                      'Consumed',
                      consumedCalories.toString(),
                      Colors.orange,
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _buildStatColumn(
                      'Burnt',
                      caloriesBurned.toString(),
                      const Color(0xFF4CAF50),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _buildStatColumn(
                      'Remaining',
                      remainingCalories.toString(),
                      remainingCalories >= 0 ? AppTheme.secondary : Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Add Meal Section
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.add_circle, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Log Your Meal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Meal Name (common for both options)
                TextField(
                  controller: _mealNameController,
                  decoration: InputDecoration(
                    labelText: 'Meal Name',
                    hintText: 'e.g., Grilled Chicken',
                    prefixIcon: const Icon(Icons.restaurant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Option selector
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text(
                          'Enter Calories',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: 0,
                        groupValue: _selectedOption,
                        onChanged: (value) =>
                            setState(() => _selectedOption = value!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppTheme.primary,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text(
                          'AI Estimate',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: 1,
                        groupValue: _selectedOption,
                        onChanged: (value) =>
                            setState(() => _selectedOption = value!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Option 0: Manual calorie entry
                if (_selectedOption == 0)
                  TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Calories',
                      hintText: 'e.g., 350',
                      prefixIcon: const Icon(Icons.local_fire_department),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                // Option 1: Description for AI estimation
                if (_selectedOption == 1) ...[
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Describe Your Meal',
                      hintText:
                          'e.g., "A small cup of ice cream" or "Two full plates of rice with curry"',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI will estimate calories based on your description',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAddingMeal ? null : _addMeal,
                    icon: _isAddingMeal
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(
                      _isAddingMeal
                          ? 'Adding...'
                          : (_selectedOption == 0
                              ? 'Add Meal'
                              : 'Let AI Estimate & Add'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppTheme.primary.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Meals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Meals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                '${todaysMeals.length} meals',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Meals List
          ...todaysMeals.asMap().entries.map((entry) {
            final index = entry.key;
            final meal = entry.value;
            return _buildMealCard(meal, index);
          }),

          // AI Suggestion Card
          if (remainingCalories > 200)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.1),
                    AppTheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'AI Suggestion',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Spacer(),
                      if (_isLoadingSuggestions)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You have $remainingCalories calories left today! Here are some meal suggestions:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDark.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_mealSuggestions.isEmpty && !_isLoadingSuggestions)
                    Text(
                      'Loading personalized suggestions...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textDark.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ..._mealSuggestions.map((suggestion) {
                      final name = suggestion['name'] as String;
                      final calories = suggestion['calories'] as int;
                      final description = suggestion['description'] as String?;
                      return _buildSuggestionItem(
                        '$name ($calories cal)',
                        description,
                      );
                    }).toList(),
                ],
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textDark.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, int index) {
    // Format timestamp from Firestore
    String timeStr = 'Today';
    if (meal['timestamp'] != null) {
      try {
        final DateTime timestamp = DateTime.parse(meal['timestamp']);
        final hour = timestamp.hour;
        final minute = timestamp.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        timeStr = '$displayHour:$minute $period';
      } catch (e) {
        timeStr = meal['time'] ?? 'Today';
      }
    } else if (meal['time'] != null) {
      timeStr = meal['time'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.restaurant, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 16),

          // Meal Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['mealName'] ?? meal['name'] ?? 'Unknown Meal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textDark.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textDark.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        meal['mealType'] ?? meal['type'] ?? 'Custom',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Show syncing indicator if meal is being synced
                    if (meal['isSyncing'] == true) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Calories
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal['calories']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Text(
                'cal',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ),

          // Favorite and Delete buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FavoriteButton(
                recipeData: meal,
                recipeSource: 'meal',
                onFavoriteChanged: _loadRealData,
              ),
              _deletingMealId == meal['id']
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.withValues(alpha: 0.6),
                      onPressed: () => _removeMeal(index),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String text, [String? description]) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textDark.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (description != null && description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
