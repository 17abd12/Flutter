import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/mock_data.dart';

class CalorieCard extends StatelessWidget {
  const CalorieCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockData.calorieData;
    final remaining = data['remaining'] as int;
    final goal = data['baseGoal'] as int;
    final progress = remaining / goal;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.boldGradient.createShader(bounds),
                child: Text(
                  'Calories',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (!isSmallScreen)
                Flexible(
                  child: Text(
                    'Remaining = Goal - Food + Exercise',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDark.withOpacity(0.6),
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            children: [
              // Left: Circular Gauge
              Expanded(
                flex: 4,
                child: Center(
                  child: SizedBox(
                    width: isSmallScreen ? 100 : 120,
                    height: isSmallScreen ? 100 : 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: isSmallScreen ? 100 : 120,
                          height: isSmallScreen ? 100 : 120,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: isSmallScreen ? 8 : 10,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primary,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              remaining.toString(),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 28 : 36,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              'Remaining',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 13,
                                color: AppTheme.textDark.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Right: Breakdown
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildBreakdownRow(
                      Icons.flag_outlined,
                      'Base Goal',
                      data['baseGoal'].toString(),
                      AppTheme.primary,
                      isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 10),
                    _buildBreakdownRow(
                      Icons.restaurant,
                      'Food',
                      data['foodConsumed'].toString(),
                      Colors.orange,
                      isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 10),
                    _buildBreakdownRow(
                      Icons.local_fire_department,
                      'Exercise',
                      data['exerciseBurned'].toString(),
                      Colors.red,
                      isSmallScreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    IconData icon,
    String label,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: isSmallScreen ? 16 : 18),
        ),
        SizedBox(width: isSmallScreen ? 8 : 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: AppTheme.textDark.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
