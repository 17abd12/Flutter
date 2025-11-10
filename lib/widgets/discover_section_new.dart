import 'package:flutter/material.dart';
import '../theme.dart';

class DiscoverSection extends StatelessWidget {
  final Function(int)? onTabChange;
  
  const DiscoverSection({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.boldGradient.createShader(bounds),
            child: Text(
              'Discover',
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
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
                  // Navigate to Recipe Generator tab (index 2)
                  if (onTabChange != null) {
                    onTabChange!(2);
                  }
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
                  // Navigate to Meal Tracking tab (index 3)
                  if (onTabChange != null) {
                    onTabChange!(3);
                  }
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
          gradient: LinearGradient(
            colors: [Colors.white, color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isSmallScreen ? 24 : 28,
              ),
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
