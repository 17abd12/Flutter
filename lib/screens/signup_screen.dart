import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../theme.dart'; // 🌿 Import the organic theme

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.organicGradient, // 🌿 Organic background
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: AppTheme.card, // 🌿 Match organic card background
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
                        "Create Account 📝",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textDark,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 🌿 Themed text fields
                      CustomTextField(
                        controller: emailController,
                        label: "Email",
                        icon: Icons.email,
                        validator: (v) => v == null || !v.contains("@")
                            ? "Enter valid email"
                            : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: passwordController,
                        label: "Password",
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (v) =>
                            v == null || v.length < 6 ? "Too short" : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: confirmController,
                        label: "Confirm Password",
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (v) => v != passwordController.text
                            ? "Passwords don't match"
                            : null,
                      ),
                      const SizedBox(height: 30),

                      // 🌿 Themed sign-up button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Sign Up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
