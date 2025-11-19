import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/calorie_card.dart';
import '../widgets/dashboard_grid.dart';
import '../widgets/weight_card.dart';
import '../widgets/discover_section_new.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  final bool isLoggedIn;
  final VoidCallback? onDataChanged;
  
  const DashboardScreen({
    super.key,
    this.onTabChange,
    this.isLoggedIn = false,
    this.onDataChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  int _refreshKey = 0; // Key to force widget refresh

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _loadUserData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Data loaded, just update loading state
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _refreshDashboard() {
    setState(() {
      _refreshKey++; // Increment key to force rebuild of all children
    });
    // Also notify parent (home screen) to refresh other tabs
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

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
          if (!widget.isLoggedIn) ...[
            IconButton(
              icon: const Icon(Icons.login, color: Colors.white),
              tooltip: 'Login',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_add, color: Colors.white),
              tooltip: 'Sign Up',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // 1. Calories Card
          CalorieCard(
            key: ValueKey('calorie_$_refreshKey'),
            isLoggedIn: widget.isLoggedIn,
          ),

          const SizedBox(height: 8),

          // 2. Dashboard Grid (Weight Input & Exercise)
          DashboardGrid(
            key: ValueKey('grid_$_refreshKey'),
            isLoggedIn: widget.isLoggedIn,
            onDataChanged: _refreshDashboard,
          ),

          const SizedBox(height: 8),

          // 3. Weight Card
          WeightCard(
            key: ValueKey('weight_$_refreshKey'),
            isLoggedIn: widget.isLoggedIn,
          ),

          const SizedBox(height: 8),

          // 4. Discover Section
          DiscoverSection(onTabChange: widget.onTabChange),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
