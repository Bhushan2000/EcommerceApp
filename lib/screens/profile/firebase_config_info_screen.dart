import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class FirebaseConfigInfoScreen extends StatefulWidget {
  const FirebaseConfigInfoScreen({super.key});

  @override
  State<FirebaseConfigInfoScreen> createState() =>
      _FirebaseConfigInfoScreenState();
}

class _FirebaseConfigInfoScreenState extends State<FirebaseConfigInfoScreen> {
  bool _isSeeding = false;

  Future<void> _handleSeedData() async {
    setState(() => _isSeeding = true);
    final productProvider = context.read<ProductProvider>();
    final error = await productProvider.seedFirestore();
    setState(() => _isSeeding = false);

    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Initial catalog seeded to Cloud Firestore successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isConnected = FirebaseService.isInitialized;

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Status & Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isConnected
                    ? AppColors.success.withAlpha(20)
                    : AppColors.warning.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isConnected
                      ? AppColors.success.withAlpha(80)
                      : AppColors.warning.withAlpha(80),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isConnected ? Icons.cloud_done : Icons.cloud_sync_outlined,
                    color: isConnected ? AppColors.success : AppColors.warning,
                    size: 36,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConnected
                              ? 'Firebase Connected'
                              : 'Running in Local / Demo Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isConnected
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isConnected
                              ? 'Connected to live Firebase Auth & Cloud Firestore.'
                              : 'Catalog, Cart, and Auth are fully functional using local seed data.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Seed Action
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border(context),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seed Catalog to Firestore',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Populate your Cloud Firestore "products" and "categories" collections with sample data in one click.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Seed Initial Catalog',
                    icon: Icons.upload_file_outlined,
                    isLoading: _isSeeding,
                    onPressed: _handleSeedData,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Setup Guide
            const Text(
              'How to connect your live Firebase project:',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildStepCard(
              context: context,
              step: '1',
              title: 'Install Firebase CLI & FlutterFire',
              code: 'npm install -g firebase-tools\ndart pub global activate flutterfire_cli',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              context: context,
              step: '2',
              title: 'Login to Firebase',
              code: 'firebase login',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              context: context,
              step: '3',
              title: 'Configure Your Project',
              code: 'flutterfire configure',
              subtitle:
                  'This automatically updates lib/firebase_options.dart and adds native google-services configs.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              context: context,
              step: '4',
              title: 'Enable Firebase Auth & Firestore in Firebase Console',
              subtitle:
                  'Go to console.firebase.google.com -> Authentication (Email/Password, Anonymous) & Cloud Firestore (test mode).',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required String step,
    required String title,
    String? subtitle,
    String? code,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
            ),
          ],
          if (code != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
