import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'alex.shopper@example.com');
  final _passwordController = TextEditingController(text: 'Password123!');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleGuestLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInGuest();
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon / Logo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Welcome heading
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to access your orders, saved addresses, and wishlist.',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Error notification
                  if (auth.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email address',
                    hint: 'name@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter email';
                      if (!val.contains('@')) return 'Invalid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Login Button
                  CustomButton(
                    text: 'Sign In',
                    isLoading: auth.isLoading,
                    onPressed: _handleLogin,
                  ),

                  const SizedBox(height: 14),

                  // Guest button
                  CustomButton(
                    text: 'Continue as Guest',
                    isOutlined: true,
                    onPressed: _handleGuestLogin,
                  ),

                  const SizedBox(height: 24),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
