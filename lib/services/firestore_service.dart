import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _db.collection('users');
  CollectionReference get _mealsCollection => _db.collection('meals');
  CollectionReference get _exercisesCollection => _db.collection('exercises');
  CollectionReference get _weightHistoryCollection => _db.collection('weight_history');
  CollectionReference get _generatedRecipesCollection => _db.collection('generated_recipes');

  // ==================== USER OPERATIONS ====================

  // Create or update user profile
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap());
    } catch (e) {
      throw 'Failed to save user profile: ${e.toString()}';
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user profile: ${e.toString()}';
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user profile: ${e.toString()}';
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw 'Failed to delete user profile: ${e.toString()}';
    }
  }

  // Stream user profile (real-time updates)
  Stream<UserModel?> streamUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // ==================== MEAL LOGGING ====================

  // Add meal entry
  Future<void> logMeal({
    required String uid,
    required String mealName,
    required int calories,
    required String mealType, // Breakfast, Lunch, Dinner, Snack
  }) async {
    try {
      await _mealsCollection.add({
        'uid': uid,
        'mealName': mealName,
        'calories': calories,
        'mealType': mealType,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to log meal: ${e.toString()}';
    }
  }

  // Get meals for a specific date
  Future<List<Map<String, dynamic>>> getMealsForDate(String uid, DateTime date) async {
    try {
      QuerySnapshot snapshot = await _mealsCollection
          .where('uid', isEqualTo: uid)
          .get();

      // Filter and sort results client-side
      final meals = snapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          })
          .where((meal) {
            try {
              if (meal['timestamp'] == null) return false;
              
              // Parse timestamp and convert to local time
              DateTime timestamp = DateTime.parse(meal['timestamp']);
              DateTime localTimestamp = timestamp.toLocal();
              
              // Compare only the date parts (ignore time)
              DateTime mealDate = DateTime(localTimestamp.year, localTimestamp.month, localTimestamp.day);
              DateTime targetDate = DateTime(date.year, date.month, date.day);
              
              return mealDate.isAtSameMomentAs(targetDate);
            } catch (e) {
              print('Error parsing timestamp: ${meal['timestamp']}, error: $e');
              return false;
            }
          })
          .toList();
      
      // Sort by timestamp descending (newest first)
      meals.sort((a, b) {
        try {
          DateTime timeA = DateTime.parse(a['timestamp']);
          DateTime timeB = DateTime.parse(b['timestamp']);
          return timeB.compareTo(timeA);
        } catch (e) {
          return 0;
        }
      });
      
      print('Found ${meals.length} meals for date ${date.year}-${date.month}-${date.day}');
      return meals;
    } catch (e) {
      print('Error getting meals: $e');
      // Return empty list if no meals or error
      return [];
    }
  }

  // Delete meal entry
  Future<void> deleteMeal(String mealId) async {
    try {
      await _mealsCollection.doc(mealId).delete();
    } catch (e) {
      throw 'Failed to delete meal: ${e.toString()}';
    }
  }

  // Get total calories consumed today
  Future<int> getTodayCaloriesConsumed(String uid) async {
    try {
      List<Map<String, dynamic>> meals = await getMealsForDate(uid, DateTime.now());
      return meals.fold<int>(0, (sum, meal) => sum + (meal['calories'] as int? ?? 0));
    } catch (e) {
      // Return 0 if no meals found or error
      return 0;
    }
  }

  // ==================== EXERCISE LOGGING ====================

  // Log exercise
  Future<void> logExercise({
    required String uid,
    required String exerciseName,
    required int caloriesBurned,
    required int durationMinutes,
  }) async {
    try {
      await _exercisesCollection.add({
        'uid': uid,
        'exerciseName': exerciseName,
        'caloriesBurned': caloriesBurned,
        'durationMinutes': durationMinutes,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to log exercise: ${e.toString()}';
    }
  }

  // Get exercises for today
  Future<List<Map<String, dynamic>>> getTodayExercises(String uid) async {
    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      QuerySnapshot snapshot = await _exercisesCollection
          .where('uid', isEqualTo: uid)
          .get();

      // Filter results client-side for date range
      final exercises = snapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          })
          .where((exercise) {
            try {
              if (exercise['timestamp'] == null) return false;
              
              DateTime timestamp = DateTime.parse(exercise['timestamp']);
              DateTime localTimestamp = timestamp.toLocal();
              DateTime exerciseDate = DateTime(localTimestamp.year, localTimestamp.month, localTimestamp.day);
              
              return exerciseDate.isAtSameMomentAs(today);
            } catch (e) {
              print('Error parsing exercise timestamp: ${exercise['timestamp']}, error: $e');
              return false;
            }
          })
          .toList();
      
      // Sort by timestamp descending (newest first)
      exercises.sort((a, b) {
        try {
          DateTime timeA = DateTime.parse(a['timestamp']);
          DateTime timeB = DateTime.parse(b['timestamp']);
          return timeB.compareTo(timeA);
        } catch (e) {
          return 0;
        }
      });
      
      print('Found ${exercises.length} exercises for today');
      return exercises;
    } catch (e) {
      print('Error getting exercises: $e');
      // Return empty list if no exercises or error
      return [];
    }
  }

  // Get total calories burned today
  Future<int> getTodayCaloriesBurned(String uid) async {
    try {
      List<Map<String, dynamic>> exercises = await getTodayExercises(uid);
      return exercises.fold<int>(0, (sum, exercise) => sum + (exercise['caloriesBurned'] as int? ?? 0));
    } catch (e) {
      // Return 0 if no exercises found or error
      return 0;
    }
  }

  // Delete exercise entry
  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _exercisesCollection.doc(exerciseId).delete();
    } catch (e) {
      throw 'Failed to delete exercise: ${e.toString()}';
    }
  }

  // ==================== WEIGHT TRACKING ====================

  // Log weight entry
  Future<void> logWeight({
    required String uid,
    required double weight,
  }) async {
    try {
      await _weightHistoryCollection.add({
        'uid': uid,
        'weight': weight,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to log weight: ${e.toString()}';
    }
  }

  // Get weight history (last N days)
  Future<List<Map<String, dynamic>>> getWeightHistory(String uid, int days) async {
    try {
      DateTime startDate = DateTime.now().subtract(Duration(days: days));

      QuerySnapshot snapshot = await _weightHistoryCollection
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: false)
          .get();

      // Filter results client-side for date range
      return snapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          })
          .where((entry) {
            try {
              DateTime timestamp = DateTime.parse(entry['timestamp']);
              return timestamp.isAfter(startDate.subtract(const Duration(seconds: 1)));
            } catch (e) {
              return false;
            }
          })
          .toList();
    } catch (e) {
      throw 'Failed to get weight history: ${e.toString()}';
    }
  }

  // ==================== DASHBOARD SUMMARY ====================

  // Get all weight history entries for a user
  Future<List<Map<String, dynamic>>> getAllWeightHistory(String uid) async {
    try {
      QuerySnapshot snapshot = await _weightHistoryCollection
          .where('uid', isEqualTo: uid)
          .get();

      final weightList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Sort client-side by timestamp descending (newest first)
      weightList.sort((a, b) {
        try {
          final aTime = DateTime.parse(a['timestamp']);
          final bTime = DateTime.parse(b['timestamp']);
          return bTime.compareTo(aTime); // Descending
        } catch (e) {
          return 0;
        }
      });
      
      return weightList;
    } catch (e) {
      throw 'Failed to get weight history: ${e.toString()}';
    }
  }

  // Get complete dashboard data for today
  Future<Map<String, dynamic>> getDashboardSummary(String uid) async {
    try {
      UserModel? user = await getUserProfile(uid);
      int caloriesConsumed = await getTodayCaloriesConsumed(uid);
      int caloriesBurned = await getTodayCaloriesBurned(uid);
      List<Map<String, dynamic>> todayMeals = await getMealsForDate(uid, DateTime.now());
      List<Map<String, dynamic>> todayExercises = await getTodayExercises(uid);

      return {
        'user': user,
        'caloriesConsumed': caloriesConsumed,
        'caloriesBurned': caloriesBurned,
        'caloriesRemaining': (user?.calorieIntakeGoal ?? 2000) - caloriesConsumed + caloriesBurned,
        'calorieGoal': user?.calorieIntakeGoal ?? 2000,
        'exerciseGoal': user?.calorieBurnGoal ?? 300,
        'todayMeals': todayMeals,
        'todayExercises': todayExercises,
      };
    } catch (e) {
      throw 'Failed to get dashboard summary: ${e.toString()}';
    }
  }

  // ==================== GENERATED RECIPES OPERATIONS ====================

  // Save a generated recipe
  Future<String> saveGeneratedRecipe({
    required String uid,
    required String recipeName,
    required Map<String, dynamic> recipeData,
  }) async {
    try {
      final docRef = await _generatedRecipesCollection.add({
        'uid': uid,
        'name': recipeName,
        'description': recipeData['description'] ?? '',
        'prepTime': recipeData['prep_time'] ?? '',
        'cookTime': recipeData['cook_time'] ?? '',
        'servings': recipeData['servings'] ?? 2,
        'difficulty': recipeData['difficulty'] ?? 'Medium',
        'calories': recipeData['nutrition']?['calories'] ?? 0,
        'protein': recipeData['nutrition']?['protein'] ?? 0,
        'carbs': recipeData['nutrition']?['carbs'] ?? 0,
        'fats': recipeData['nutrition']?['fats'] ?? 0,
        'ingredients': recipeData['ingredients'] ?? [],
        'instructions': recipeData['instructions'] ?? [],
        'tips': recipeData['tips'] ?? [],
        'cuisine': recipeData['cuisine'] ?? 'Unknown',
        'mealType': recipeData['meal_type'] ?? 'Dinner',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to save generated recipe: ${e.toString()}';
    }
  }

  // Get all generated recipes for a user (without ordering to avoid index requirement)
  Future<List<Map<String, dynamic>>> getUserGeneratedRecipes(String uid) async {
    try {
      QuerySnapshot snapshot = await _generatedRecipesCollection
          .where('uid', isEqualTo: uid)
          .get();

      // Sort in memory by createdAt
      final recipes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
          '_timestamp': (data['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0,
        };
      }).toList();
      
      // Sort by timestamp descending (newest first)
      recipes.sort((a, b) => (b['_timestamp'] as int).compareTo(a['_timestamp'] as int));
      
      // Remove the temporary _timestamp field
      for (var recipe in recipes) {
        recipe.remove('_timestamp');
      }
      
      return recipes;
    } catch (e) {
      throw 'Failed to get generated recipes: ${e.toString()}';
    }
  }

  // Get a single generated recipe by ID
  Future<Map<String, dynamic>?> getGeneratedRecipe(String recipeId) async {
    try {
      DocumentSnapshot doc = await _generatedRecipesCollection.doc(recipeId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      throw 'Failed to get generated recipe: ${e.toString()}';
    }
  }

  // Delete a generated recipe
  Future<void> deleteGeneratedRecipe(String recipeId) async {
    try {
      await _generatedRecipesCollection.doc(recipeId).delete();
    } catch (e) {
      throw 'Failed to delete generated recipe: ${e.toString()}';
    }
  }
}
