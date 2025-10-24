/// Mock Data for AI Meal Planner App
class MockData {
  // User Profile
  static const Map<String, dynamic> userProfile = {
    'name': 'Sarah Johnson',
    'age': 28,
    'weight': 80.0,
    'goalWeight': 73.0,
    'height': 165,
    'dailyCalorieGoal': 1500,
  };

  // Today's Calorie Data
  static const Map<String, dynamic> calorieData = {
    'baseGoal': 1500,
    'foodConsumed': 0,
    'exerciseBurned': 0,
    'remaining': 1500,
  };

  // Steps Data
  static const Map<String, dynamic> stepsData = {
    'current': 0,
    'goal': 10000,
    'isConnected': false,
  };

  // Exercise Data
  static const Map<String, dynamic> exerciseData = {
    'caloriesBurned': 0,
    'duration': '0:00',
    'exercises': <Map<String, dynamic>>[],
  };

  // Weight History (Last 90 days)
  static List<Map<String, dynamic>> weightHistory = [
    {'date': '23/07', 'weight': 87.0},
    {'date': '22/08', 'weight': 87.0},
    {'date': '21/09', 'weight': 82.0},
    {'date': '21/10', 'weight': 80.0},
  ];

  // Meal History
  static List<Map<String, dynamic>> meals = [
    {
      'name': 'Greek Yogurt Bowl',
      'type': 'Breakfast',
      'time': '8:30 AM',
      'calories': 320,
      'protein': 18,
      'carbs': 42,
      'fats': 8,
      'image': '🥣',
    },
    {
      'name': 'Grilled Chicken Salad',
      'type': 'Lunch',
      'time': '1:00 PM',
      'calories': 450,
      'protein': 35,
      'carbs': 25,
      'fats': 22,
      'image': '🥗',
    },
    {
      'name': 'Salmon with Quinoa',
      'type': 'Dinner',
      'time': '7:30 PM',
      'calories': 580,
      'protein': 42,
      'carbs': 48,
      'fats': 24,
      'image': '🐟',
    },
  ];

  // Recipes
  static List<Map<String, dynamic>> recipes = [
    {
      'name': 'Avocado Toast',
      'calories': 280,
      'time': '10 min',
      'difficulty': 'Easy',
      'protein': 12,
      'image': '🥑',
      'ingredients': [
        'Whole grain bread',
        'Avocado',
        'Eggs',
        'Cherry tomatoes',
      ],
    },
    {
      'name': 'Chicken Stir Fry',
      'calories': 420,
      'time': '25 min',
      'difficulty': 'Medium',
      'protein': 38,
      'image': '🍜',
      'ingredients': [
        'Chicken breast',
        'Mixed vegetables',
        'Soy sauce',
        'Rice',
      ],
    },
    {
      'name': 'Berry Smoothie Bowl',
      'calories': 340,
      'time': '5 min',
      'difficulty': 'Easy',
      'protein': 15,
      'image': '🫐',
      'ingredients': ['Mixed berries', 'Greek yogurt', 'Banana', 'Granola'],
    },
  ];

  // Workouts
  static List<Map<String, dynamic>> workouts = [
    {
      'name': 'Morning Yoga',
      'duration': 30,
      'calories': 120,
      'type': 'Flexibility',
      'icon': '🧘',
    },
    {
      'name': 'HIIT Cardio',
      'duration': 20,
      'calories': 250,
      'type': 'Cardio',
      'icon': '🏃',
    },
    {
      'name': 'Strength Training',
      'duration': 45,
      'calories': 200,
      'type': 'Strength',
      'icon': '💪',
    },
  ];

  // Sleep Data
  static Map<String, dynamic> sleepData = {
    'lastNight': 7.5,
    'goal': 8.0,
    'quality': 'Good',
    'bedtime': '11:00 PM',
    'wakeup': '6:30 AM',
  };

  // Nutrient Alerts
  static List<Map<String, dynamic>> nutrientAlerts = [
    {
      'nutrient': 'Vitamin D',
      'status': 'Low',
      'current': 45,
      'recommended': 75,
      'unit': 'IU',
      'severity': 'warning',
    },
    {
      'nutrient': 'Protein',
      'status': 'Good',
      'current': 95,
      'recommended': 90,
      'unit': 'g',
      'severity': 'success',
    },
    {
      'nutrient': 'Fiber',
      'status': 'Low',
      'current': 18,
      'recommended': 25,
      'unit': 'g',
      'severity': 'warning',
    },
  ];

  // AI Learning Insights
  static List<Map<String, dynamic>> aiInsights = [
    {
      'title': 'Protein Preference',
      'description': 'You prefer high-protein breakfasts',
      'icon': '🥚',
      'confidence': 0.92,
    },
    {
      'title': 'Dietary Pattern',
      'description': 'You avoid red meat on weekends',
      'icon': '🥗',
      'confidence': 0.85,
    },
    {
      'title': 'Meal Timing',
      'description': 'You often skip lunch when busy',
      'icon': '⏰',
      'confidence': 0.78,
    },
    {
      'title': 'Cuisine Preference',
      'description': 'You enjoy spicy Indian dishes',
      'icon': '🌶️',
      'confidence': 0.88,
    },
  ];

  // Habit Tracking
  static List<Map<String, dynamic>> habits = [
    {
      'name': 'Drink 8 glasses of water',
      'current': 5,
      'goal': 8,
      'icon': '💧',
      'streak': 12,
    },
    {
      'name': 'Eat 5 servings of vegetables',
      'current': 3,
      'goal': 5,
      'icon': '🥬',
      'streak': 8,
    },
    {
      'name': 'No snacking after 8 PM',
      'current': 1,
      'goal': 1,
      'icon': '🌙',
      'streak': 15,
    },
  ];

  // Macro Breakdown for Today
  static Map<String, dynamic> macroBreakdown = {
    'carbs': {'current': 180, 'goal': 188, 'percentage': 40},
    'protein': {'current': 90, 'goal': 94, 'percentage': 25},
    'fats': {'current': 55, 'goal': 58, 'percentage': 35},
  };
}
