import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/mock_data.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isLoggedIn = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _recipes = [];
  String? _errorMessage;
  bool _isCached = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final user = _authService.currentUser;
    
    setState(() {
      _isLoggedIn = user != null;
      _isLoading = _isLoggedIn; // Only show loading if logged in
      _errorMessage = null;
    });

    if (!_isLoggedIn) {
      // Not logged in - use mock data
      setState(() {
        _recipes = MockData.recipes;
        _isLoading = false;
      });
      return;
    }

    // User is logged in - fetch from API
    try {
      // Get user profile for API request
      final userProfile = await _firestoreService.getUserProfile(user!.uid);
      
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // Calculate today's calories and get recent meal names
      final today = DateTime.now();
      final mealsToday = await _firestoreService.getMealsForDate(user.uid, today);
      final caloriesIntakeToday = mealsToday.fold<int>(
        0, 
        (sum, meal) => sum + (meal['calories'] as int? ?? 0)
      );
      
      // Get recent meal names for personalization (last 3 meals)
      final recentMealNames = mealsToday
          .map((meal) => meal['mealName'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .take(3)
          .toList();

      // Call API for personalized recipes
      final response = await _apiService.getPopularRecipes(
        userId: user.uid,
        mealPreference: userProfile.mealPreference ?? 'balanced',
        calorieGoal: userProfile.calorieIntakeGoal,
        caloriesIntakeToday: caloriesIntakeToday,
        currentWeight: userProfile.currentWeight,
        targetWeight: userProfile.targetWeight,
        height: userProfile.height,
        age: userProfile.age,
        gender: userProfile.gender.toLowerCase(),
        goal: userProfile.goal,
        activityLevel: userProfile.activityLevel,
        recentMeals: recentMealNames,  // Pass recent meals for personalization
      );

      // Parse response
      final recipesData = response['recipes'] as List<dynamic>;
      _isCached = response['cached'] ?? false;
      
      setState(() {
        _recipes = recipesData.map((recipe) {
          final imageUrl = recipe['image_url'];
          
          return {
            'name': recipe['name'],
            'calories': recipe['calories'],
            'protein': recipe['protein'],
            'carbs': recipe['carbs'],
            'fats': recipe['fats'],
            'description': recipe['description'],
            'image_url': imageUrl,
            'prep_time': recipe['prep_time'],
            'cook_time': recipe['cook_time'],
            'time': '${recipe['prep_time']} + ${recipe['cook_time']}',
            'difficulty': recipe['difficulty'],
            'ingredients': recipe['ingredients'], // Add ingredients from API
            'instructions': recipe['instructions'],
            'image': '🍽️', // Default emoji for display
          };
        }).toList();
        _isLoading = false;
      });
      
    } catch (e) {
      
      if (!mounted) return;
      
      // Fallback to mock data on error
      setState(() {
        _recipes = MockData.recipes;
        _isLoading = false;
        _errorMessage = 'Using offline recipes';
      });
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
          'Recipes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.8,
          ),
        ),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadRecipes,
              tooltip: 'Refresh recipes',
            ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading personalized recipes...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.sunsetGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cook, eat, log, repeat',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Discover healthy recipes tailored to your goals',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isCached)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cached,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Cached',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recipe Categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isLoggedIn ? 'Popular Recipes For You' : 'Popular Recipes',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (!_isLoggedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Demo Mode',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Recipe Cards
                if (_recipes.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No recipes available'),
                    ),
                  )
                else
                  ..._recipes.map((recipe) => _buildRecipeCard(context, recipe)),
              ],
            ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    final imageUrl = recipe['image_url'];
    final hasValidUrl = imageUrl != null && 
                        imageUrl.toString().isNotEmpty && 
                        imageUrl.toString() != 'N/A' &&
                        (imageUrl.toString().startsWith('http://') || 
                         imageUrl.toString().startsWith('https://'));
    
    // Use CORS proxy for web platform to avoid CORS issues
    String getProxiedUrl(String url) {
      // For web, use a CORS proxy
      if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
        // Use AllOrigins CORS proxy
        return 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}';
      }
      return url;
    }
    
    final displayUrl = hasValidUrl ? getProxiedUrl(imageUrl) : '';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: hasValidUrl
                  ? Image.network(
                      displayUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to gradient with emoji if image fails to load
                        return Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.3),
                                AppTheme.secondary.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              recipe['image'] ?? '🍽️',
                              style: const TextStyle(fontSize: 60),
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.1),
                                AppTheme.secondary.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withOpacity(0.3),
                            AppTheme.secondary.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          recipe['image'] ?? '🍽️',
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Recipe stats
                  Row(
                    children: [
                      _buildStatChip(
                        Icons.local_fire_department,
                        '${recipe['calories']} cal',
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.access_time,
                        recipe['time'],
                        AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.restaurant,
                        recipe['difficulty'],
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Protein info
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: AppTheme.textDark.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe['protein']}g protein',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textDark.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
