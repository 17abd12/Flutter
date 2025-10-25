import 'package:flutter/material.dart';
import '../theme.dart';
import '../screens/smart_recipe_generator_screen.dart';
import '../screens/real_time_meal_adjustment_screen.dart';

class DiscoverSection extends StatelessWidget {
  const DiscoverSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: isSmallScreen ? 8 : 12,
            mainAxisSpacing: isSmallScreen ? 8 : 12,
            childAspectRatio: 1.1,
            children: [
              _buildDiscoverCard(
                context: context,
                icon: Icons.auto_awesome,
                title: 'Recipe Generator',
                subtitle: 'AI-powered recipes',
                color: Colors.orange,
                isSmallScreen: isSmallScreen,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SmartRecipeGeneratorScreen(),
                    ),
                  );
                },
              ),
              _buildDiscoverCard(
                context: context,
                icon: Icons.timeline,
                title: 'Meal Tracking',
                subtitle: 'Log meals in real-time',
                color: Colors.red,
                isSmallScreen: isSmallScreen,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const RealTimeMealAdjustmentScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: AppTheme.textDark.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
