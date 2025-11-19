import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final bool isLoggedIn;

  const ProfileScreen({super.key, this.isLoggedIn = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _userData;
  bool _isLoading = true;

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
        final userData = await _firestoreService.getUserProfile(user.uid);
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return _buildNotLoggedInView();
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(),
        body: const Center(
          child: Text('No profile data found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildBodyMetricsSection(),
              const SizedBox(height: 24),
              _buildGoalsSection(),
              const SizedBox(height: 24),
              _buildCalorieGoalsSection(),
              const SizedBox(height: 24),
              _buildMealPreferenceSection(),
              const SizedBox(height: 24),
              _buildMotivationSection(),
              const SizedBox(height: 24),
              _buildLogoutButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppTheme.boldGradient),
      ),
      elevation: 4,
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.white, Color(0xFFE0E0E0)],
        ).createShader(bounds),
        child: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Not Logged In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please login to view your profile information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textDark.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Login to access your profile',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 50,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userData!.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow('Age', '${_userData!.age} years', Icons.cake),
        _buildInfoRow('Gender', _userData!.gender, Icons.wc),
        _buildInfoRow(
          'Member Since',
          _formatDate(_userData!.createdAt),
          Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildBodyMetricsSection() {
    return _buildSection(
      title: 'Body Metrics',
      icon: Icons.monitor_weight_outlined,
      children: [
        _buildInfoRow(
          'Current Weight',
          '${_userData!.currentWeight} kg',
          Icons.monitor_weight,
        ),
        _buildInfoRow(
          'Target Weight',
          '${_userData!.targetWeight} kg',
          Icons.flag,
        ),
        _buildInfoRow(
          'Height',
          '${_userData!.height} cm',
          Icons.height,
        ),
        _buildInfoRow(
          'BMI',
          _userData!.bmi.toStringAsFixed(1),
          Icons.analytics,
        ),
        _buildInfoRow(
          'Remaining',
          '${_userData!.remainingWeight.toStringAsFixed(1)} kg',
          Icons.trending_down,
        ),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return _buildSection(
      title: 'Fitness Goals',
      icon: Icons.emoji_events_outlined,
      children: [
        _buildInfoRow('Goal', _userData!.goal, Icons.fitness_center),
        _buildInfoRow(
          'Activity Level',
          _userData!.activityLevel,
          Icons.run_circle,
        ),
        _buildInfoRow('Duration', _userData!.duration, Icons.timer),
      ],
    );
  }

  Widget _buildCalorieGoalsSection() {
    return _buildSection(
      title: 'Calorie Goals',
      icon: Icons.restaurant_outlined,
      children: [
        _buildInfoRow(
          'Daily Intake Goal',
          '${_userData!.calorieIntakeGoal} kcal',
          Icons.restaurant_menu,
        ),
        _buildInfoRow(
          'Daily Burn Goal',
          '${_userData!.calorieBurnGoal} kcal',
          Icons.local_fire_department,
        ),
      ],
    );
  }

  Widget _buildMealPreferenceSection() {
    final mealPref = _userData?.mealPreference;
    
    return _buildSection(
      title: 'Meal Preference',
      icon: Icons.restaurant_menu,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: mealPref == null || mealPref.isEmpty 
                ? Colors.grey.shade100 
                : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: mealPref == null || mealPref.isEmpty 
                  ? Colors.grey.shade300 
                  : Colors.green.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                mealPref == null || mealPref.isEmpty 
                    ? Icons.info_outline 
                    : Icons.check_circle_outline,
                color: mealPref == null || mealPref.isEmpty 
                    ? Colors.grey.shade500 
                    : Colors.green.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mealPref == null || mealPref.isEmpty 
                      ? 'No meal preference set' 
                      : mealPref,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textDark,
                    fontWeight: mealPref == null || mealPref.isEmpty 
                        ? FontWeight.normal 
                        : FontWeight.w500,
                    fontStyle: mealPref == null || mealPref.isEmpty 
                        ? FontStyle.italic 
                        : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationSection() {
    if (_userData!.motivation.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: 'Motivation',
      icon: Icons.favorite_outline,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.pink.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote, color: Colors.pink.shade400, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _userData!.motivation,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textDark,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textDark.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true && mounted) {
              try {
                await _authService.signOut();
                if (!mounted) return;
                
                // Navigate back to auth wrapper (will redirect to logged out view)
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error logging out: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
