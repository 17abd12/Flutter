import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service for FastAPI backend integration
/// 
/// Configuration:
/// - Development: Update baseUrl to your local FastAPI server (e.g., 'http://localhost:8000')
/// - Production: Update baseUrl to your deployed FastAPI URL or Firebase Cloud Function URL
/// 
/// To switch between FastAPI and Firebase Cloud Functions:
/// 1. FastAPI: Set baseUrl to FastAPI endpoint
/// 2. Firebase: Deploy functions and update baseUrl to Cloud Function URL
class ApiService {
  // CONFIGURE YOUR API BASE URL HERE
  static const String baseUrl = 'http://localhost:8000'; // Change to your FastAPI server URL
  
  // Alternative configurations:
  // static const String baseUrl = 'https://your-api.com'; // Deployed FastAPI
  // static const String baseUrl = 'https://us-central1-your-project.cloudfunctions.net'; // Firebase Functions
  
  final http.Client _client = http.Client();
  
  // Helper method to get headers with authentication token
  Map<String, String> _getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // 1. POPULAR RECIPES API
  // ============================================================

  /// Get 5 popular recipe suggestions based on user preferences
  /// 
  /// Endpoint: POST /api/v1/recipes/popular
  Future<Map<String, dynamic>> getPopularRecipes({
    required String userId,
    required String mealPreference,
    required int calorieGoal,
    required int caloriesIntakeToday,
    required double currentWeight,
    required double targetWeight,
    required double height,
    required int age,
    required String gender,
    required String goal,
    required String activityLevel,
    List<String>? recentMeals,
    List<String>? cuisines,
    double diversityFactor = 0.3,  // 0.0 = fully personalized, 1.0 = fully random
    String? token,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'user_id': userId,
        'meal_preference': mealPreference,
        'calorie_goal': calorieGoal,
        'calories_intake_today': caloriesIntakeToday,
        'goal': goal,
        'diversity_factor': diversityFactor,
      };
      
      // Add optional personalization fields
      if (recentMeals != null && recentMeals.isNotEmpty) {
        requestBody['recent_meals'] = recentMeals;
      }
      if (cuisines != null && cuisines.isNotEmpty) {
        requestBody['cuisines'] = cuisines;
      }
      
      final response = await _client.post(
        Uri.parse('$baseUrl/api/v1/recipes/popular'),
        headers: _getHeaders(token: token),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get popular recipes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting popular recipes: $e');
    }
  }

  // ============================================================
  // 2. EXERCISE CALORIE CALCULATOR API
  // ============================================================

  /// Calculate calories burned based on exercise type, duration, and intensity
  /// 
  /// Endpoint: POST /api/v1/exercise/calculate-calories
  /// Intensity options: "low", "moderate", "high", "very_high"
  Future<Map<String, dynamic>> calculateExerciseCalories({
    required String userId,
    required String exerciseName,
    required int durationMinutes,
    required String intensity,
    required double currentWeight,
    required double height,
    required int age,
    required String gender,
    String? token,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/v1/exercise/calculate-calories'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'user_id': userId,
          'exercise_name': exerciseName,
          'duration_minutes': durationMinutes,
          'intensity': intensity,
          'current_weight': currentWeight,
          'height': height,
          'age': age,
          'gender': gender,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to calculate exercise calories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calculating exercise calories: $e');
    }
  }

  // ============================================================
  // 3. REAL-TIME MEAL ADJUSTMENT API
  // ============================================================

  /// Analyze meal description and return estimated calorie and nutritional information
  /// 
  /// Endpoint: POST /api/v1/meals/analyze-description
  Future<Map<String, dynamic>> analyzeMealDescription({
    required String userId,
    required String mealDescription,
    required String mealTime,
    required int calorieGoal,
    required int caloriesIntakeToday,
    required int caloriesBurntToday,
    required double currentWeight,
    required double targetWeight,
    required String goal,
    String? token,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/v1/meals/analyze-description'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'user_id': userId,
          'meal_description': mealDescription,
          'meal_time': mealTime,
          'calorie_goal': calorieGoal,
          'calories_intake_today': caloriesIntakeToday,
          'calories_burnt_today': caloriesBurntToday,
          'current_weight': currentWeight,
          'target_weight': targetWeight,
          'goal': goal,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze meal description: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error analyzing meal description: $e');
    }
  }

  // ============================================================
  // 4. SMART RECIPE GENERATOR API
  // ============================================================

  /// Generate personalized recipes based on ingredients, cuisine, meal type, and user goals
  /// 
  /// Endpoint: POST /api/recipes/generate
  /// 
  /// Cuisine options: "Italian", "Mexican", "Chinese", "Indian", "American", "Mediterranean", etc.
  /// Meal type options: "breakfast", "lunch", "dinner", "snack"
  /// Difficulty options: "easy", "medium", "hard"
  Future<Map<String, dynamic>> generateSmartRecipe({
    required String userId,
    required List<String> ingredients,
    required String cuisineType,
    required String mealType,
    required String difficulty,
    required String mealPreference,
    required int calorieGoal,
    required int caloriesIntakeToday,
    required int caloriesBurntToday,
    required double currentWeight,
    required double targetWeight,
    required double height,
    required int age,
    required String gender,
    required String goal,
    required String activityLevel,
    List<Map<String, dynamic>>? favoriteRecipes,
    String? token,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/v1/recipes/generate'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'user_id': userId,
          'ingredients': ingredients,
          'cuisine_type': cuisineType,
          'meal_type': mealType,
          'difficulty': difficulty,
          'meal_preference': mealPreference,
          'calorie_goal': calorieGoal,
          'calories_intake_today': caloriesIntakeToday,
          'calories_burnt_today': caloriesBurntToday,
          'current_weight': currentWeight,
          'target_weight': targetWeight,
          'height': height,
          'age': age,
          'gender': gender,
          'goal': goal,
          'activity_level': activityLevel,
          'favorite_recipes': favoriteRecipes ?? [],
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate smart recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating smart recipe: $e');
    }
  }

  // ============================================================
  // 5. MEAL SUGGESTIONS API
  // ============================================================

  /// Get AI-powered meal suggestions based on remaining calories
  /// 
  /// Endpoint: POST /api/v1/meals/suggestions
  Future<Map<String, dynamic>> getMealSuggestions({
    required String userId,
    required int remainingCalories,
    required String mealPreference,
    required String goal,
    List<String>? recentMeals,
    List<Map<String, dynamic>>? favoriteRecipes,
    String? token,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/v1/meals/suggestions'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'user_id': userId,
          'remaining_calories': remainingCalories,
          'meal_preference': mealPreference,
          'goal': goal,
          'recent_meals': recentMeals ?? [],
          'favorite_recipes': favoriteRecipes ?? [],
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get meal suggestions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting meal suggestions: $e');
    }
  }

  /// Clear meal suggestions cache after adding a meal
  /// 
  /// Endpoint: POST /api/v1/meals/suggestions/clear
  Future<void> clearMealSuggestionsCache({
    required String userId,
    String? token,
  }) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/api/v1/meals/suggestions/clear?user_id=$userId'),
        headers: _getHeaders(token: token),
      );
    } catch (e) {
      // Ignore cache clear errors
      print('Warning: Failed to clear meal suggestions cache: $e');
    }
  }

  // Cleanup
  void dispose() {
    _client.close();
  }
}
