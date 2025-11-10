import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/calorie_card.dart';
import '../widgets/dashboard_grid.dart';
import '../widgets/weight_card.dart';
import '../widgets/discover_section_new.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const DashboardScreen({super.key, this.onTabChange});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoggedIn = false;

  void _handleLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    ).then((value) {
      if (value == true) {
        setState(() {
          _isLoggedIn = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged in successfully!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    });
  }

  void _handleSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    ).then((value) {
      if (value == true) {
        setState(() {
          _isLoggedIn = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.boldGradient),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFE0E0E0)],
          ).createShader(bounds),
          child: const Text(
            'Today',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        actions: [
          if (!_isLoggedIn) ...[
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Login',
              onPressed: _handleLogin,
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Sign Up',
              onPressed: _handleSignup,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _handleLogout,
            ),
          ],
          // TextButton(
          //   onPressed: () {
          //     // Edit action
          //   },
          //   child: const Text(
          //     'Edit',
          //     style: TextStyle(
          //       fontSize: 16,
          //       color: Colors.blue,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // 1. Calories Card
          const CalorieCard(),

          const SizedBox(height: 8),

          // 2. Dashboard Grid (Weight Input & Exercise)
          const DashboardGrid(),

          const SizedBox(height: 8),

          // 3. Weight Card
          const WeightCard(),

          const SizedBox(height: 8),

          // 4. Discover Section
          DiscoverSection(onTabChange: widget.onTabChange),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
