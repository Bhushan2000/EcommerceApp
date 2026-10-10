import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.sendPasswordReset(email);
    if (ok && mounted) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _sent
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mark_email_read_outlined,
                            size: 60, color: AppColors.success),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Check your email',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We sent instructions to ${_emailController.text.trim()} to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: 'Back to Sign In',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Forgot your password?',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your registered email address and we will send you a reset link.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email address',
                      hint: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Send Reset Link',
                      isLoading: auth.isLoading,
                      onPressed: _handleReset,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
