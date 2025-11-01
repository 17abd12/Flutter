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
                  'Weight',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
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
          SizedBox(height: isSmallScreen ? 16 : 20),
          // Simple Line Chart with padding for labels
          Container(
            padding: const EdgeInsets.only(left: 30, right: 10, bottom: 20),
            child: SizedBox(
              height: isSmallScreen ? 120 : 140,
              child: CustomPaint(
                size: Size(double.infinity, isSmallScreen ? 120 : 140),
                painter: WeightChartPainter(weightData, goalWeight),
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
                _buildLegendItem(AppTheme.primary, 'Goal'),
                const SizedBox(width: 32),
                _buildLegendItem(AppTheme.secondary, 'Actual'),
              ],
            ),
          ),
        ],
      ),
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

  WeightChartPainter(this.data, this.goalWeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw goal line
    paint.color = AppTheme.primary;
    final goalY = size.height * 0.5; // Position goal line at 50%
    canvas.drawLine(Offset(0, goalY), Offset(size.width, goalY), paint);

    // Draw goal line dots for clarity
    final goalDotPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, goalY), 6, goalDotPaint);
    canvas.drawCircle(Offset(size.width, goalY), 6, goalDotPaint);

    // Draw actual weight line
    paint.color = AppTheme.secondary;
    paint.strokeWidth = 3.5;

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

        // Draw larger, more visible points with shadow
        final dotPaint = Paint()
          ..color = AppTheme.secondary.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 8, dotPaint); // Shadow/glow
        
        dotPaint.color = AppTheme.secondary;
        canvas.drawCircle(Offset(x, y), 6, dotPaint); // Main dot
        
        // White center for better visibility
        dotPaint.color = Colors.white;
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
      canvas.drawPath(path, paint);
    }

    // Draw Y-axis labels with better positioning
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final weights = [95, 87, 80, 73];
    for (int i = 0; i < weights.length; i++) {
      textPainter.text = TextSpan(
        text: weights[i].toString(),
        style: TextStyle(
          color: AppTheme.textDark.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-28, (size.height / (weights.length - 1)) * i - 6),
      );
    }

    // Draw X-axis labels with better spacing
    for (int i = 0; i < data.length; i++) {
      textPainter.text = TextSpan(
        text: data[i]['date'] as String,
        style: TextStyle(
          color: AppTheme.textDark.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      final x = (size.width / (data.length - 1)) * i;
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
