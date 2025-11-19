import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../widgets/custom_textfield.dart';
import '../theme.dart'; // 🌿 Import the organic theme
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.organicGradient, // 🌿 Organic gradient
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Home button at top
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: 'Home',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      color: AppTheme.card, // 🌿 Match card background
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Welcome Back 👋",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppTheme.textDark,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 25),

                              // 🌿 Themed custom text fields
                              CustomTextField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email,
                                validator: (v) => v == null || !v.contains("@")
                                    ? "Invalid email"
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: passwordController,
                                label: "Password",
                                icon: Icons.lock,
                                obscureText: true,
                                validator: (v) => v == null || v.length < 6
                                    ? "Too short"
                                    : null,
                              ),
                              const SizedBox(height: 30),

                              // 🌿 Themed button
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: AppTheme.textLight,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text("Login"),
                              ),
                              const SizedBox(height: 15),

                              // 🌿 Themed signup text link
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Don't have an account? Sign Up",
                                  style: TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle login with Firebase
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = await _authService.signInWithEmailPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      if (user == null) {
        throw 'Failed to sign in';
      }

      if (!mounted) return;

      // Navigate back - AuthWrapper will handle showing HomeScreen with user data
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome back! 🎉'),
          backgroundColor: AppTheme.primary,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
