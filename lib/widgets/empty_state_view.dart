import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'custom_button.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(25),
                      AppColors.primary.withAlpha(10),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(20),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (buttonText != null && onButtonPressed != null) ...[
                const SizedBox(height: 30),
                SizedBox(
                  width: 220,
                  child: CustomButton(
                    text: buttonText!,
                    onPressed: onButtonPressed,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
