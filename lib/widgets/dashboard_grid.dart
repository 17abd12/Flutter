import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/mock_data.dart';

class DashboardGrid extends StatefulWidget {
  const DashboardGrid({super.key});

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  void _showAddWeightDialog() {
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
            onPressed: () {
              // TODO: Save weight data
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Weight ${weightController.text} kg saved!'),
                  backgroundColor: AppTheme.primary,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddExerciseDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
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
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.scale,
                color: Colors.blue,
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              'Weight',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              'Tap to add today\'s weight',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 13,
                color: AppTheme.textDark.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppTheme.primary,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(bool isSmallScreen) {
    final exerciseData = MockData.exerciseData;
    return GestureDetector(
      onTap: _showAddExerciseDialog,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppTheme.primary,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  '${exerciseData['caloriesBurned']} cal',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: AppTheme.primary,
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  '${exerciseData['duration']} hr',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddExerciseDialog extends StatefulWidget {
  const AddExerciseDialog({super.key});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  int _selectedOption = 0; // 0: Manual calories, 1: AI estimation
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _selectedIntensity = 'Medium';

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
          onPressed: () {
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

            // TODO: Save exercise data and estimate calories using AI if needed
            String message;
            if (_selectedOption == 0) {
              message =
                  'Exercise "${_exerciseNameController.text}" with ${_caloriesController.text} cal added!';
            } else {
              message =
                  'Exercise "${_exerciseNameController.text}" (${_durationController.text} min, $_selectedIntensity intensity) added! AI will estimate calories.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppTheme.primary,
              ),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
