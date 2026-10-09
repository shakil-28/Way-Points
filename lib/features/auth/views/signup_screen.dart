import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

/// Screen 1b: Sign Up & Registration Screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join Bengal Highway Explorers',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Get real-time corridor alerts, historical detour recommendations, and custom drive logs.',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Full Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Rahim Ahmed',
                  prefixIcon: const Icon(Symbols.person, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'rahim@example.com',
                  prefixIcon: const Icon(Symbols.mail, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: !authCtrl.isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Secure Password',
                  prefixIcon: const Icon(Symbols.lock, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      authCtrl.isPasswordVisible ? Symbols.visibility : Symbols.visibility_off,
                      size: 20,
                    ),
                    onPressed: authCtrl.togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              // Terms Acceptance Checkbox
              Row(
                children: [
                  Checkbox(
                    value: authCtrl.acceptedTerms,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) => authCtrl.setAcceptedTerms(val ?? false),
                  ),
                  Expanded(
                    child: Text(
                      'I accept the WayPoint Navigation Terms & Privacy Policy.',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Register CTA
              ElevatedButton(
                onPressed: authCtrl.isLoading || !authCtrl.acceptedTerms
                    ? null
                    : () async {
                  final success = await authCtrl.signUp(
                    _nameController.text,
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (success && context.mounted) {
                    context.go(AppRoutes.profileSetup);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: primaryTextColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: authCtrl.isLoading
                    ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: primaryTextColor),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue to Driver Setup',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Symbols.arrow_forward, size: 20, color: AppTheme.accentNeon),
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
