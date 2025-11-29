import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../theme.dart'; // 🌿 Import the organic theme
import 'email_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.organicGradient, // 🌿 Organic background
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Home button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: const Icon(
                      Icons.home,
                      color: AppTheme.textDark,
                      size: 32,
                    ),
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                  ),
                ),
              ),
              Expanded(
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
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppTheme.textDark,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 25),

                              // 🌿 Themed text fields
                              CustomTextField(
                                controller: nameController,
                                label: "Full Name",
                                icon: Icons.person,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Name is required"
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: ageController,
                                label: "Age",
                                icon: Icons.cake,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Age is required";
                                  int? age = int.tryParse(v);
                                  if (age == null || age < 13 || age > 120) {
                                    return "Enter valid age (13-120)";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
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
                                validator: (v) => v == null || v.length < 6
                                    ? "Too short"
                                    : null,
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
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EmailVerificationScreen(
                                                email: emailController.text.trim(),
                                                password: passwordController.text,
                                                name: nameController.text.trim(),
                                                age: int.parse(ageController.text),
                                                isNewUser: true, // Signup flow - go to goal setup after verification
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: AppTheme.textLight,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 15,
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
                                    : const Text("Sign Up"),
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
}
