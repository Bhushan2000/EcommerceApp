import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'firestore_service.dart';

class AuthService {
  final FirestoreService _firestoreService;
  final StreamController<AppUser?> _mockAuthController =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentMockUser;

  AuthService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    if (!FirebaseService.isInitialized) {
      // Create a default demo guest user
      _currentMockUser = AppUser(
        id: 'demo_user_1',
        email: 'alex.shopper@example.com',
        displayName: 'Alex Morgan',
        photoUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
        street: '742 Evergreen Terrace',
        city: 'Springfield',
        state: 'OR',
        zipCode: '97477',
        country: 'United States',
        phoneNumber: '+1 (555) 019-2834',
      );
      _mockAuthController.add(_currentMockUser);
    }
  }

  Stream<AppUser?> get authStateChanges {
    if (FirebaseService.isInitialized) {
      return fb.FirebaseAuth.instance.authStateChanges().asyncMap((fbUser) async {
        if (fbUser == null) return null;
        final profile = await _firestoreService.getUserProfile(fbUser.uid);
        if (profile != null) return profile;
        return AppUser(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? 'Customer',
          photoUrl: fbUser.photoURL,
          phoneNumber: fbUser.phoneNumber,
        );
      });
    } else {
      return _mockAuthController.stream;
    }
  }

  Future<AppUser?> getCurrentUser() async {
    if (FirebaseService.isInitialized) {
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser == null) return null;
      final profile = await _firestoreService.getUserProfile(fbUser.uid);
      if (profile != null) return profile;
      return AppUser(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? 'Customer',
        photoUrl: fbUser.photoURL,
        phoneNumber: fbUser.phoneNumber,
      );
    } else {
      return _currentMockUser;
    }
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    if (FirebaseService.isInitialized) {
      final cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = cred.user!;
      final profile = await _firestoreService.getUserProfile(fbUser.uid);
      if (profile != null) return profile;
      final newUser = AppUser(
        id: fbUser.uid,
        email: fbUser.email ?? email,
        displayName: fbUser.displayName ?? email.split('@').first,
      );
      await _firestoreService.saveUserProfile(newUser);
      return newUser;
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      _currentMockUser = AppUser(
        id: 'user_${email.hashCode.abs()}',
        email: email,
        displayName: email.split('@').first.capitalize(),
        street: '123 Market Street',
        city: 'San Francisco',
        state: 'CA',
        zipCode: '94105',
        country: 'United States',
      );
      _mockAuthController.add(_currentMockUser);
      return _currentMockUser!;
    }
  }

  Future<AppUser> signUpWithEmail(
      String email, String password, String name) async {
    if (FirebaseService.isInitialized) {
      final cred = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = cred.user!;
      await fbUser.updateDisplayName(name);
      final user = AppUser(
        id: fbUser.uid,
        email: email,
        displayName: name,
      );
      await _firestoreService.saveUserProfile(user);
      return user;
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      _currentMockUser = AppUser(
        id: 'user_${email.hashCode.abs()}',
        email: email,
        displayName: name,
        street: '123 Market Street',
        city: 'San Francisco',
        state: 'CA',
        zipCode: '94105',
        country: 'United States',
      );
      _mockAuthController.add(_currentMockUser);
      return _currentMockUser!;
    }
  }

  Future<AppUser> signInAnonymously() async {
    if (FirebaseService.isInitialized) {
      final cred = await fb.FirebaseAuth.instance.signInAnonymously();
      final fbUser = cred.user!;
      final user = AppUser(
        id: fbUser.uid,
        email: 'guest_${fbUser.uid.substring(0, 5)}@guest.aura',
        displayName: 'Guest Shopper',
      );
      await _firestoreService.saveUserProfile(user);
      return user;
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      _currentMockUser = AppUser(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@aura.com',
        displayName: 'Guest Shopper',
      );
      _mockAuthController.add(_currentMockUser);
      return _currentMockUser!;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (FirebaseService.isInitialized) {
      await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Demo: Password reset email sent to $email');
    }
  }

  Future<void> updateProfile(AppUser updatedUser) async {
    if (FirebaseService.isInitialized) {
      await _firestoreService.saveUserProfile(updatedUser);
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        if (updatedUser.displayName.isNotEmpty) {
          await fbUser.updateDisplayName(updatedUser.displayName);
        }
        if (updatedUser.photoUrl != null) {
          await fbUser.updatePhotoURL(updatedUser.photoUrl);
        }
      }
    } else {
      _currentMockUser = updatedUser;
      _mockAuthController.add(_currentMockUser);
    }
  }

  Future<void> signOut() async {
    if (FirebaseService.isInitialized) {
      await fb.FirebaseAuth.instance.signOut();
    } else {
      _currentMockUser = null;
      _mockAuthController.add(null);
    }
  }

  void dispose() {
    _mockAuthController.close();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
