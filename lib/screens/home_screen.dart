import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'recipes_screen.dart';
import 'smart_recipe_generator_screen.dart';
import 'real_time_meal_adjustment_screen.dart';
import 'logs_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'profile_screen.dart';
import 'generated_recipes_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final bool isLoggedIn;
  
  const HomeScreen({super.key, this.isLoggedIn = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  int _refreshKey = 0; // Key to trigger rebuilds across tabs
  bool _currentLoginState = false;

  @override
  void initState() {
    super.initState();
    _currentLoginState = widget.isLoggedIn;
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (mounted) {
        final isLoggedIn = user != null;
        if (_currentLoginState != isLoggedIn) {
          setState(() {
            _currentLoginState = isLoggedIn;
            _refreshKey++; // Force rebuild all screens with new login state
          });
        }
      }
    });
  }

  void _refreshAllScreens() {
    setState(() {
      _refreshKey++;
    });
  }

  List<Widget> get _screens => [
    DashboardScreen(
      key: ValueKey('dashboard_$_refreshKey'),
      onTabChange: _onItemTapped,
      isLoggedIn: _currentLoginState,
      onDataChanged: _refreshAllScreens,
    ),
    const RecipesScreen(),
    SmartRecipeGeneratorScreen(
      key: ValueKey('generator_$_refreshKey'),
    ),
    RealTimeMealAdjustmentScreen(
      key: ValueKey('meals_$_refreshKey'),
      onDataChanged: _refreshAllScreens,
    ),
    const LogsScreen(),
    GeneratedRecipesScreen(
      key: ValueKey('saved_recipes_$_refreshKey'),
    ),
    ProfileScreen(
      key: ValueKey('profile_$_refreshKey'),
      isLoggedIn: _currentLoginState,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'Generate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: 'Tracking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    List<Widget> drawerItems = [
      DrawerHeader(
        decoration: const BoxDecoration(
          gradient: AppTheme.organicGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sarah Johnson',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'sarah.j@email.com',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      ListTile(
        leading: const Icon(Icons.person, color: AppTheme.primary),
        title: const Text('Profile'),
        onTap: () {
          Navigator.pop(context);
          setState(() {
            _selectedIndex = 4; // Navigate to profile tab
          });
        },
      ),
      ListTile(
        leading: const Icon(Icons.bookmark, color: AppTheme.primary),
        title: const Text('My Generated Recipes'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GeneratedRecipesScreen()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.settings, color: AppTheme.primary),
        title: const Text('Settings'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.notifications, color: AppTheme.primary),
        title: const Text('Notifications'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      const Divider(),
    ];

    // Add login/signup or logout based on auth state
    if (!widget.isLoggedIn) {
      drawerItems.addAll([
        ListTile(
          leading: const Icon(Icons.login, color: AppTheme.primary),
          title: const Text('Login'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_add, color: AppTheme.primary),
          title: const Text('Sign Up'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            );
          },
        ),
      ]);
    } else {
      drawerItems.add(
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () async {
            try {
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      );
    }

    drawerItems.addAll([
      const Divider(),
      ListTile(
        leading: const Icon(Icons.help_outline, color: AppTheme.primary),
        title: const Text('Help & Support'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.info_outline, color: AppTheme.primary),
        title: const Text('About'),
        onTap: () {
          Navigator.pop(context);
          _showAboutDialog(context);
        },
      ),
    ]);

    return Drawer(
      child: Container(
        color: AppTheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: drawerItems,
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About AI Meal Planner'),
        content: const Text(
          'AI Meal Planner v1.0\n\n'
          'A modern nutrition tracking and meal planning app powered by AI.\n\n'
          'This app helps you track your meals, exercise, and achieve your fitness goals.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
