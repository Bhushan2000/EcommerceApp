import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static String? _errorMessage;

  static bool get isInitialized => _isInitialized;
  static String? get errorMessage => _errorMessage;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      debugPrint('✅ Firebase successfully initialized with current platform options.');
    } catch (e) {
      _isInitialized = false;
      _errorMessage = e.toString();
      debugPrint('⚠️ Firebase initialization deferred or running in Demo Mode: $e');
      debugPrint('💡 To connect your live Firebase project, run: flutterfire configure');
    }
  }
}
