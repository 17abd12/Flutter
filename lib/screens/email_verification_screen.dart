import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/recipe_generation_state.dart';
import 'goal_setup_screen.dart';
import 'home_screen.dart';
import '../theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  final int age;
  final bool isNewUser; // true = new signup, false = existing user logging in

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.isNewUser,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isResending = false;
  late Timer _timer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _generateAndSendCode();
  }

  Future<void> _generateAndSendCode() async {
    // For new users, create the account first (if not already created)
    if (widget.isNewUser) {
      final currentUser = _authService.currentUser;
      
      // Only create account if no user is currently signed in
      if (currentUser == null) {
        try {
          await _authService.signUpWithEmailPassword(
            widget.email,
            widget.password,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating account: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
    }

    // Send email verification link (Firebase built-in)
    try {
      await _authService.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyEmail() async {
    setState(() => _isLoading = true);

    try {
      // Reload user to check if email has been verified via link click
      await _authService.reloadUser();

      if (_authService.isEmailVerified) {
        // Email verified! Check if user profile exists in Firestore
        final user = _authService.currentUser;
        
        if (user != null) {
          final firestoreService = FirestoreService();
          final userProfile = await firestoreService.getUserProfile(user.uid);
          
          if (userProfile != null) {
            // Profile exists - go to home screen
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(isLoggedIn: true),
                ),
              );
            }
          } else {
            // Profile doesn't exist - go to goal setup (collect personal info)
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalSetupScreen(
                    email: widget.email,
                    password: widget.password,
                    name: widget.name,
                    age: widget.age,
                  ),
                ),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified yet. Please click the link in your email.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    if (_resendCountdown > 0) return;

    setState(() => _isResending = true);

    try {
      await _authService.sendEmailVerification();

      setState(() {
        _resendCountdown = 60;
        _isResending = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resending email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isResending = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        // Clear generated recipe state
        RecipeGenerationState().reset();
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (_resendCountdown > 0) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Email Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 64,
                  color: AppTheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'We sent a verification link to\n${widget.email}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Click the verification link in the email we sent',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textDark,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Then click the button below to continue',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textDark,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _verifyEmail,
                  icon: _isLoading ? null : const Icon(Icons.verified_user),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('I Have Verified My Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.6),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Resend Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: (_resendCountdown == 0 && !_isResending) ? _resendEmail : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _resendCountdown == 0 ? AppTheme.primary : Colors.grey,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          ),
                        )
                      : Text(
                          _resendCountdown > 0
                              ? 'Resend Email (${_resendCountdown}s)'
                              : 'Resend Verification Email',
                          style: TextStyle(
                            color: _resendCountdown == 0 ? AppTheme.primary : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout & Return to Home'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Help Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Didn\'t receive the email?',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Check your spam/junk folder\n• Make sure email address is correct\n• Try resending the verification email',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textDark.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
