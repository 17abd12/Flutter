import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/mock_data.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class WeightCard extends StatefulWidget {
  final bool isLoggedIn;
  
  const WeightCard({super.key, this.isLoggedIn = false});

  @override
  State<WeightCard> createState() => _WeightCardState();
}

class _WeightCardState extends State<WeightCard> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Map<String, dynamic>> _allWeightData = []; // Cache all data
  double _goalWeight = 70.0;
  double _currentWeight = 75.0;
  int _selectedDays = 90; // 7, 30, or 90 days
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _loadWeightData();
    } else {
      // Use mock data when not logged in
      _allWeightData = MockData.weightHistory;
      _goalWeight = (MockData.userProfile['goalWeight'] as num?)?.toDouble() ?? 70.0;
      _currentWeight = (MockData.userProfile['currentWeight'] as num?)?.toDouble() ?? 75.0;
      _isLoading = false;
    }
  }

  Future<void> _loadWeightData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Load user profile for goal weight
        final userProfile = await _firestoreService.getUserProfile(user.uid);
        
        // Load ALL weight history (cache it)
        final weightHistory = await _firestoreService.getAllWeightHistory(user.uid);
        
        if (mounted) {
          setState(() {
            _goalWeight = userProfile?.targetWeight ?? 70.0;
            _currentWeight = userProfile?.currentWeight ?? 75.0;
            _allWeightData = weightHistory;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading weight data: $e');
      if (mounted) {
        setState(() {
          _allWeightData = [];
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredData() {
    if (_allWeightData.isEmpty) return [];
    
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _selectedDays));
    
    final filtered = _allWeightData.where((entry) {
      try {
        final timestamp = DateTime.parse(entry['timestamp']);
        return timestamp.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).toList();
    
    // Remove duplicates - keep latest entry for same date
    final Map<String, Map<String, dynamic>> uniqueByDate = {};
    for (var entry in filtered) {
      try {
        final timestamp = DateTime.parse(entry['timestamp']);
        final dateKey = '${timestamp.year}-${timestamp.month}-${timestamp.day}';
        
        // If this date already exists, compare timestamps and keep the later one
        if (uniqueByDate.containsKey(dateKey)) {
          final existingTimestamp = DateTime.parse(uniqueByDate[dateKey]!['timestamp']);
          if (timestamp.isAfter(existingTimestamp)) {
            uniqueByDate[dateKey] = entry;
          }
        } else {
          uniqueByDate[dateKey] = entry;
        }
      } catch (e) {
        // Skip invalid entries
      }
    }
    
    // Convert back to list and sort
    final uniqueList = uniqueByDate.values.toList();
    uniqueList.sort((a, b) {
      try {
        final aTime = DateTime.parse(a['timestamp']);
        final bTime = DateTime.parse(b['timestamp']);
        return aTime.compareTo(bTime);
      } catch (e) {
        return 0;
      }
    });
    
    // Format dates for display
    return uniqueList.map((entry) {
      try {
        final timestamp = DateTime.parse(entry['timestamp']);
        final date = '${timestamp.month}/${timestamp.day}';
        return {
          ...entry,
          'date': date,
        };
      } catch (e) {
        return entry;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final filteredData = _getFilteredData();

    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          heightFactor: 5,
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

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
                  'Weight Progress',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              // Time period selector
              PopupMenuButton<int>(
                initialValue: _selectedDays,
                onSelected: (days) {
                  setState(() {
                    _selectedDays = days;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 7, child: Text('Last 7 days')),
                  const PopupMenuItem(value: 30, child: Text('Last 30 days')),
                  const PopupMenuItem(value: 90, child: Text('Last 90 days')),
                ],
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 10,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Last $_selectedDays days',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: AppTheme.textDark.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 2 : 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: isSmallScreen ? 16 : 18,
                        color: AppTheme.textDark.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          // Weight stats
          if (filteredData.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Current', '${_currentWeight.toStringAsFixed(1)} kg', AppTheme.secondary),
                  _buildStatColumn('Target', '${_goalWeight.toStringAsFixed(1)} kg', AppTheme.primary),
                  _buildStatColumn('Progress', '${(_currentWeight - _goalWeight).abs().toStringAsFixed(1)} kg', Colors.orange),
                ],
              ),
            ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          // Chart
          Container(
            padding: const EdgeInsets.only(left: 30, right: 10, bottom: 20),
            child: SizedBox(
              height: isSmallScreen ? 120 : 140,
              child: filteredData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monitor_weight_outlined,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No weight data for this period',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomPaint(
                      size: Size(double.infinity, isSmallScreen ? 120 : 140),
                      painter: WeightChartPainter(
                        filteredData,
                        _goalWeight,
                        _selectedDays,
                      ),
                    ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppTheme.primary, 'Target'),
                const SizedBox(width: 24),
                _buildLegendItem(AppTheme.secondary, 'Actual'),
              ],
            ),
          ),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textDark.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class WeightChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double goalWeight;
  final int selectedDays;

  WeightChartPainter(this.data, this.goalWeight, this.selectedDays);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Calculate min and max weights for dynamic scaling
    final allWeights = data.isNotEmpty 
        ? data.map((e) => e['weight'] as double).toList()
        : <double>[];
    allWeights.add(goalWeight); // Always include goal weight
    final minWeight = allWeights.isNotEmpty 
        ? allWeights.reduce((a, b) => a < b ? a : b) - 2
        : goalWeight - 5;
    final maxWeight = allWeights.isNotEmpty 
        ? allWeights.reduce((a, b) => a > b ? a : b) + 2
        : goalWeight + 5;
    final weightRange = maxWeight - minWeight;

    // Helper function to map weight to Y coordinate
    double getY(double weight) {
      if (weightRange == 0) return size.height / 2;
      return size.height - ((weight - minWeight) / weightRange * size.height);
    }

    // ALWAYS draw goal line (full width, dashed)
    final goalY = getY(goalWeight);
    final goalLinePaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    // Dashed line for goal
    const dashWidth = 5;
    const dashSpace = 5;
    double currentX = 0;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, goalY),
        Offset(currentX + dashWidth, goalY),
        goalLinePaint,
      );
      currentX += dashWidth + dashSpace;
    }

    // Draw actual weight data if available
    if (data.isEmpty) {
      // Case 0: No data - only target line shown (already drawn above)
      return;
    } else if (data.length == 1) {
      // Case 1: Single data point - show as dot on left side
      final x = size.width * 0.15; // 15% from left
      final y = getY(data[0]['weight'] as double);
      
      final dotPaint = Paint()..style = PaintingStyle.fill;
      dotPaint.color = AppTheme.secondary.withOpacity(0.3);
      canvas.drawCircle(Offset(x, y), 10, dotPaint);
      
      dotPaint.color = AppTheme.secondary;
      canvas.drawCircle(Offset(x, y), 7, dotPaint);
      
      dotPaint.color = Colors.white;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    } else {
      // Case 2+: Multiple data points - proportional positioning
      // Calculate what portion of the selected period has data
      final dataSpanDays = _calculateDataSpanDays();
      final dataPortionOfGraph = dataSpanDays / selectedDays;
      final usableWidth = size.width * dataPortionOfGraph.clamp(0.3, 1.0); // Min 30% of graph
      
      paint.color = AppTheme.secondary;
      paint.strokeWidth = 3.5;
      
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final x = (usableWidth / (data.length - 1)) * i;
        final weight = data[i]['weight'] as double;
        final y = getY(weight);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        // Draw points
        final dotPaint = Paint()..style = PaintingStyle.fill;
        dotPaint.color = AppTheme.secondary.withOpacity(0.3);
        canvas.drawCircle(Offset(x, y), 8, dotPaint);
        
        dotPaint.color = AppTheme.secondary;
        canvas.drawCircle(Offset(x, y), 6, dotPaint);
        
        dotPaint.color = Colors.white;
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
      canvas.drawPath(path, paint);
    }

    // Draw Y-axis labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final yLabels = _getYAxisLabels(minWeight, maxWeight);
    
    for (final label in yLabels) {
      textPainter.text = TextSpan(
        text: label['text'],
        style: TextStyle(
          color: AppTheme.textDark.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-28, getY(label['value']) - 6),
      );
    }

    // Draw X-axis labels
    if (data.isEmpty) {
      // No data - show period label in center
      textPainter.text = TextSpan(
        text: 'No data',
        style: TextStyle(
          color: AppTheme.textDark.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width / 2 - textPainter.width / 2, size.height + 8),
      );
    } else if (data.length == 1) {
      // Single point - show date on left
      textPainter.text = TextSpan(
        text: data[0]['date'] as String,
        style: TextStyle(
          color: AppTheme.textDark.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width * 0.15 - textPainter.width / 2, size.height + 8),
      );
    } else {
      // Multiple points - show labels with appropriate spacing
      final maxLabels = 5;
      final step = data.length > maxLabels ? (data.length / maxLabels).ceil() : 1;
      final dataSpanDays = _calculateDataSpanDays();
      final dataPortionOfGraph = dataSpanDays / selectedDays;
      final usableWidth = size.width * dataPortionOfGraph.clamp(0.3, 1.0);
      
      for (int i = 0; i < data.length; i += step) {
        textPainter.text = TextSpan(
          text: data[i]['date'] as String,
          style: TextStyle(
            color: AppTheme.textDark.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        final x = (usableWidth / (data.length - 1)) * i;
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height + 8),
        );
      }
    }
  }

  int _calculateDataSpanDays() {
    if (data.length < 2) return 1;
    
    try {
      final firstDate = DateTime.parse(data.first['timestamp']);
      final lastDate = DateTime.parse(data.last['timestamp']);
      return lastDate.difference(firstDate).inDays + 1;
    } catch (e) {
      return data.length;
    }
  }

  List<Map<String, dynamic>> _getYAxisLabels(double min, double max) {
    final labels = <Map<String, dynamic>>[];
    final step = (max - min) / 3;
    
    for (int i = 0; i < 4; i++) {
      final value = max - (step * i);
      labels.add({
        'value': value,
        'text': value.toStringAsFixed(0),
      });
    }
    
    return labels;
  }

  @override
  bool shouldRepaint(WeightChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.goalWeight != goalWeight ||
        oldDelegate.selectedDays != selectedDays;
  }
}
