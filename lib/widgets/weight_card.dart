import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/mock_data.dart';

class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weightData = MockData.weightHistory;
    final goalWeight = MockData.userProfile['goalWeight'] as double;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Weight',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Container(
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
                      'Last 90 days',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: AppTheme.textDark.withOpacity(0.7),
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
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          // Simple Line Chart
          SizedBox(
            height: isSmallScreen ? 120 : 140,
            child: CustomPaint(
              size: Size(double.infinity, isSmallScreen ? 120 : 140),
              painter: WeightChartPainter(weightData, goalWeight),
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppTheme.primary, 'Goal'),
              const SizedBox(width: 20),
              _buildLegendItem(AppTheme.secondary, 'Actual'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textDark.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class WeightChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double goalWeight;

  WeightChartPainter(this.data, this.goalWeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw goal line
    paint.color = AppTheme.primary;
    final goalY = size.height * 0.5; // Position goal line at 50%
    canvas.drawLine(Offset(0, goalY), Offset(size.width, goalY), paint);

    // Draw actual weight line
    paint.color = AppTheme.secondary;
    paint.strokeWidth = 3.0;

    if (data.length > 1) {
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final x = (size.width / (data.length - 1)) * i;
        final weight = data[i]['weight'] as double;
        // Map weight 70-95 to screen height
        final y = size.height - ((weight - 70) / 25 * size.height);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        // Draw point
        canvas.drawCircle(Offset(x, y), 5, Paint()..color = AppTheme.secondary);
      }
      canvas.drawPath(path, paint);
    }

    // Draw Y-axis labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final weights = [95, 87, 80, 73];
    for (int i = 0; i < weights.length; i++) {
      textPainter.text = TextSpan(
        text: weights[i].toString(),
        style: TextStyle(
          color: AppTheme.textDark.withOpacity(0.6),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-25, (size.height / (weights.length - 1)) * i - 6),
      );
    }

    // Draw X-axis labels
    for (int i = 0; i < data.length; i++) {
      textPainter.text = TextSpan(
        text: data[i]['date'] as String,
        style: TextStyle(
          color: AppTheme.textDark.withOpacity(0.6),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      final x = (size.width / (data.length - 1)) * i;
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height + 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
