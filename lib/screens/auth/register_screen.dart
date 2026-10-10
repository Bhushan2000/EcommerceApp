import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to terms and conditions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Icon / Logo
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(50),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Join Aura Market',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create an account to start shopping and track orders effortlessly.',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 24),

                if (auth.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withAlpha(80)),
                    ),
                    child: Text(
                      auth.errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'e.g. Jordan Smith',
                  prefixIcon: Icons.person_outline,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'jordan@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter email';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Repeat password',
                  prefixIcon: Icons.lock_reset_outlined,
                  isPassword: true,
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Checkbox(
                      value: _agreeTerms,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _agreeTerms = val ?? false);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to the Terms of Service & Privacy Policy',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                CustomButton(
                  text: 'Create Account',
                  isLoading: auth.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
