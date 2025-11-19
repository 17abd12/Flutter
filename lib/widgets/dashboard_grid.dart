import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/mock_data.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class DashboardGrid extends StatefulWidget {
  final bool isLoggedIn;
  final VoidCallback? onDataChanged;
  
  const DashboardGrid({
    super.key,
    this.isLoggedIn = false,
    this.onDataChanged,
  });

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  void _showAddWeightDialog() {
    if (!widget.isLoggedIn) {
      _showLoginPrompt();
      return;
    }
    
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Today\'s Weight'),
        content: TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            hintText: 'Enter your weight',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final weightText = weightController.text.trim();
              if (weightText.isEmpty) return;
              
              final weight = double.tryParse(weightText);
              if (weight == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid weight'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                final user = _authService.currentUser;
                if (user != null) {
                  await _firestoreService.logWeight(uid: user.uid, weight: weight);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Weight $weight kg saved!'),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                    Navigator.pop(context);
                    // Trigger a refresh of the parent widget
                    widget.onDataChanged?.call();
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving weight: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog() {
    if (!widget.isLoggedIn) {
      _showLoginPrompt();
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AddExerciseDialog(
        onExerciseAdded: () {
          widget.onDataChanged?.call(); // Call parent callback
        },
      ),
    );
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login or sign up to add weight and exercise data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight Input Card
          Expanded(child: _buildWeightInputCard(isSmallScreen)),
          SizedBox(width: isSmallScreen ? 8 : 12),
          // Exercise Card
          Expanded(child: _buildExerciseCard(isSmallScreen)),
        ],
      ),
    );
  }

  Widget _buildWeightInputCard(bool isSmallScreen) {
    return GestureDetector(
      onTap: _showAddWeightDialog,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 160 : 180,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.scale,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Flexible(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    ).createShader(bounds),
                    child: Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 3),
                Flexible(
                  child: Text(
                    'Tap to add weight',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 11,
                      color: AppTheme.textDark.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 4 : 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppTheme.primary,
                        size: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(bool isSmallScreen) {
    final exerciseData = MockData.exerciseData;
    return GestureDetector(
      onTap: _showAddExerciseDialog,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 160 : 180,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.orange.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                        ).createShader(bounds),
                        child: Text(
                          'Exercise',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 15 : 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 4 : 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppTheme.primary,
                        size: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: isSmallScreen ? 16 : 18,
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      Flexible(
                        child: Text(
                          '${exerciseData['caloriesBurned']} cal',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                            color: AppTheme.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 3 : 4),
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: AppTheme.primary,
                        size: isSmallScreen ? 16 : 18,
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      Flexible(
                        child: Text(
                          '${exerciseData['duration']} hr',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 13,
                            color: AppTheme.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddExerciseDialog extends StatefulWidget {
  final VoidCallback? onExerciseAdded;
  
  const AddExerciseDialog({super.key, this.onExerciseAdded});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedOption = 0; // 0: Manual calories, 1: AI estimation
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _selectedIntensity = 'Medium';
  bool _isLoading = false;

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _caloriesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Exercise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name field (common for both options)
            TextField(
              controller: _exerciseNameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'e.g., Running, Cycling',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Option selector
            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    title: const Text('Manual', style: TextStyle(fontSize: 14)),
                    value: 0,
                    groupValue: _selectedOption,
                    onChanged: (value) =>
                        setState(() => _selectedOption = value!),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Option 0: Manual calories input
            if (_selectedOption == 0)
              TextField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories Burned',
                  hintText: 'Enter calories',
                  border: OutlineInputBorder(),
                  suffixText: 'cal',
                ),
              ),

            // Option 1: Duration and intensity for AI estimation
            if (_selectedOption == 1) ...[
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'Enter duration',
                  border: OutlineInputBorder(),
                  suffixText: 'min',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIntensity,
                decoration: const InputDecoration(
                  labelText: 'Intensity',
                  border: OutlineInputBorder(),
                ),
                items: ['Low', 'Medium', 'High', 'Very High'].map((intensity) {
                  return DropdownMenuItem(
                    value: intensity,
                    child: Text(intensity),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedIntensity = value!),
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
                        'AI will estimate calories based on activity',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_exerciseNameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter exercise name')),
              );
              return;
            }

            if (_selectedOption == 0 && _caloriesController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter calories burned')),
              );
              return;
            }

            if (_selectedOption == 1 && _durationController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter duration')),
              );
              return;
            }

            setState(() => _isLoading = true);

            try {
              final user = _authService.currentUser;
              if (user == null) throw 'Not logged in';

              int caloriesBurned;
              int durationMinutes;

              if (_selectedOption == 0) {
                // Manual calories
                caloriesBurned = int.parse(_caloriesController.text);
                durationMinutes = 30; // Default duration
              } else {
                // AI estimation (mock for now - estimate based on duration and intensity)
                durationMinutes = int.parse(_durationController.text);
                double multiplier;
                switch (_selectedIntensity) {
                  case 'Low': multiplier = 3.0; break;
                  case 'Medium': multiplier = 5.0; break;
                  case 'High': multiplier = 7.0; break;
                  case 'Very High': multiplier = 9.0; break;
                  default: multiplier = 5.0;
                }
                caloriesBurned = (durationMinutes * multiplier).round();
              }

              await _firestoreService.logExercise(
                uid: user.uid,
                exerciseName: _exerciseNameController.text,
                caloriesBurned: caloriesBurned,
                durationMinutes: durationMinutes,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Exercise "${_exerciseNameController.text}" added! ($caloriesBurned cal)'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
                Navigator.pop(context);
                widget.onExerciseAdded?.call();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
