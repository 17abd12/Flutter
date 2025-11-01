import 'package:flutter/material.dart';
import '../theme.dart';

class RealTimeMealAdjustmentScreen extends StatefulWidget {
  const RealTimeMealAdjustmentScreen({super.key});

  @override
  State<RealTimeMealAdjustmentScreen> createState() =>
      _RealTimeMealAdjustmentScreenState();
}

class _RealTimeMealAdjustmentScreenState
    extends State<RealTimeMealAdjustmentScreen> {
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _selectedOption = 0; // 0: Enter calories, 1: AI estimate from description

  int dailyGoal = 1500;
  int consumedCalories = 650;

  List<Map<String, dynamic>> todaysMeals = [
    {
      'name': 'Greek Yogurt Bowl',
      'time': '8:30 AM',
      'calories': 320,
      'type': 'Breakfast',
    },
    {
      'name': 'Chicken Salad',
      'time': '1:00 PM',
      'calories': 330,
      'type': 'Lunch',
    },
  ];

  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addMeal() {
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
      // AI estimation from description
      if (_descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter meal description'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // TODO: Call AI API to estimate calories from description
      // For now, using mock estimation based on description length
      calories = _estimateCaloriesFromDescription(_descriptionController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'AI estimated $calories calories from your description',
          ),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      todaysMeals.add({
        'name': _mealNameController.text,
        'time': TimeOfDay.now().format(context),
        'calories': calories,
        'type': 'Custom',
      });
      consumedCalories += calories;
      _mealNameController.clear();
      _caloriesController.clear();
      _descriptionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal added successfully!'),
        backgroundColor: AppTheme.primary,
      ),
    );
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

  void _removeMeal(int index) {
    setState(() {
      consumedCalories -= todaysMeals[index]['calories'] as int;
      todaysMeals.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingCalories = dailyGoal - consumedCalories;
    final progress = consumedCalories / dailyGoal;

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
                    onPressed: _addMeal,
                    icon: const Icon(Icons.add),
                    label: Text(
                      _selectedOption == 0
                          ? 'Add Meal'
                          : 'Let AI Estimate & Add',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                  _buildSuggestionItem(
                    'Grilled salmon with vegetables (380 cal)',
                  ),
                  _buildSuggestionItem('Quinoa bowl with chickpeas (420 cal)'),
                  _buildSuggestionItem('Turkey wrap with hummus (350 cal)'),
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
                  meal['name'],
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
                      meal['time'],
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
                        meal['type'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.withValues(alpha: 0.6),
            onPressed: () => _removeMeal(index),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
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
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textDark.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
