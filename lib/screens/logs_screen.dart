import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Filter and display options
  int _selectedTabIndex = 0; // 0: All, 1: Meals, 2: Exercises
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isLoggedIn = false;

  // Data
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _combinedLogs = [];

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
      await _loadLogs();
    }
  }

  Future<void> _loadLogs() async {
    if (!_isLoggedIn) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final mealsRaw = await _firestoreService.getMealsForDate(user.uid, _selectedDate);
        final allExercises = await _firestoreService.getTodayExercises(user.uid);

        // Add logType to meals
        final meals = mealsRaw.map((m) => {...m, 'logType': 'meal'}).toList();

        // Filter exercises by selected date
        final filteredExercises = allExercises
            .where((exercise) {
              try {
                if (exercise['timestamp'] == null) return false;
                DateTime timestamp = DateTime.parse(exercise['timestamp']);
                DateTime localTimestamp = timestamp.toLocal();
                DateTime exerciseDate =
                    DateTime(localTimestamp.year, localTimestamp.month, localTimestamp.day);
                DateTime selectedDate =
                    DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                return exerciseDate.isAtSameMomentAs(selectedDate);
              } catch (e) {
                return false;
              }
            })
            .toList();

        // Add logType to exercises
        final exercisesWithType = filteredExercises.map((e) => {...e, 'logType': 'exercise'}).toList();

        // Create combined logs with type indicator
        final allLogs = <Map<String, dynamic>>[
          ...meals,
          ...exercisesWithType,
        ];

        // Sort by timestamp descending
        allLogs.sort((a, b) {
          try {
            DateTime timeA = DateTime.parse(a['timestamp'] ?? DateTime.now().toIso8601String());
            DateTime timeB = DateTime.parse(b['timestamp'] ?? DateTime.now().toIso8601String());
            return timeB.compareTo(timeA);
          } catch (e) {
            return 0;
          }
        });

        setState(() {
          _meals = meals;
          _exercises = exercisesWithType;
          _combinedLogs = allLogs;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading logs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              secondary: AppTheme.secondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _loadLogs();
    }
  }

  void _changeDate(int days) async {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
    await _loadLogs();
  }

  String _formatDate(String? timestamp) {
    try {
      if (timestamp == null) return '';
      DateTime dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return '';
    }
  }

  String _formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  List<Map<String, dynamic>> _getDisplayLogs() {
    switch (_selectedTabIndex) {
      case 1:
        return _meals;
      case 2:
        return _exercises;
      default:
        return _combinedLogs;
    }
  }

  int _getTotalCaloriesConsumed() {
    return _meals.fold<int>(0, (sum, meal) => sum + (meal['calories'] as int? ?? 0));
  }

  int _getTotalCaloriesBurned() {
    return _exercises.fold<int>(0, (sum, ex) => sum + (ex['caloriesBurned'] as int? ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Logs'),
          centerTitle: true,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: AppTheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please login to view logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    final displayLogs = _getDisplayLogs();
    final caloriesConsumed = _getTotalCaloriesConsumed();
    final caloriesBurned = _getTotalCaloriesBurned();
    final netCalories = caloriesConsumed - caloriesBurned;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date Navigation Card
            Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _changeDate(-1),
                        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _formatFullDate(_selectedDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tap to select date',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _changeDate(1),
                        icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Summary Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Consumed',
                          '$caloriesConsumed',
                          'cal',
                          Colors.orange,
                          Icons.local_fire_department,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Burned',
                          '$caloriesBurned',
                          'cal',
                          Colors.green,
                          Icons.fitness_center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Net',
                          '$netCalories',
                          'cal',
                          netCalories >= 0 ? Colors.blue : Colors.red,
                          Icons.trending_down,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildTabButton(0, 'All Logs', Icons.all_inbox),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Meals', Icons.restaurant),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Exercises', Icons.fitness_center),
                ],
              ),
            ),

            // Logs List
            if (_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              )
            else if (displayLogs.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(
                      _selectedTabIndex == 1
                          ? Icons.restaurant_menu
                          : _selectedTabIndex == 2
                              ? Icons.fitness_center
                              : Icons.list_alt,
                      size: 64,
                      color: AppTheme.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedTabIndex == 1
                          ? 'No meals logged today'
                          : _selectedTabIndex == 2
                              ? 'No exercises logged today'
                              : 'No activity logged today',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textDark.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: displayLogs.map((log) {
                    if (log['logType'] == 'meal') {
                      return _buildMealLogCard(log);
                    } else {
                      return _buildExerciseLogCard(log);
                    }
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedTabIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  width: 3,
                ),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppTheme.primary : AppTheme.textDark.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppTheme.primary : AppTheme.textDark.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealLogCard(Map<String, dynamic> meal) {
    final calories = meal['calories'] as int? ?? 0;
    final mealName = meal['mealName'] as String? ?? 'Meal';
    final mealType = meal['mealType'] as String? ?? 'Custom';
    final timestamp = meal['timestamp'] as String? ?? '';
    final time = _formatDate(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant, color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        mealType,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textDark.withValues(alpha: 0.5),
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
                '$calories',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Text(
                'cal',
                style: TextStyle(fontSize: 10, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseLogCard(Map<String, dynamic> exercise) {
    final caloriesBurned = exercise['caloriesBurned'] as int? ?? 0;
    final exerciseName = exercise['exerciseName'] as String? ?? 'Exercise';
    final duration = exercise['durationMinutes'] as int? ?? 0;
    final timestamp = exercise['timestamp'] as String? ?? '';
    final time = _formatDate(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.green, size: 22),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: AppTheme.textDark.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${duration}m',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textDark.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppTheme.textDark.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calories Burned
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$caloriesBurned',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text(
                'cal',
                style: TextStyle(fontSize: 10, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
