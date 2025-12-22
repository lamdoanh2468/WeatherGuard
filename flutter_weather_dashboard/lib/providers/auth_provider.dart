import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initAuthListener();
  }

  // Initialize auth state listener
  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await loadUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  // Load user data from Firestore
  Future<void> loadUserData() async {
    if (_user != null) {
      try {
        _userData = await _authService.getUserData(_user!.uid);
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  // Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signOut();

      _user = null;
      _userData = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_user != null) {
        // Update display name in Firebase Auth
        if (name != null) {
          await _authService.updateProfile(displayName: name);
        }

        // Update user data in Firestore
        await _authService.updateUserData(
          uid: _user!.uid,
          name: name,
          phone: phone,
          address: address,
        );

        // Reload user data
        await loadUserData();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Email
  Future<bool> updateEmail(String newEmail, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Re-authenticate first
      await _authService.reauthenticateUser(password);

      // Update email
      await _authService.updateEmail(newEmail);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Password
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Re-authenticate first
      await _authService.reauthenticateUser(currentPassword);

      // Update password
      await _authService.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete Account
  Future<bool> deleteAccount(String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Re-authenticate first
      await _authService.reauthenticateUser(password);

      // Delete account
      await _authService.deleteAccount();

      _user = null;
      _userData = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Send Email Verification
  Future<bool> sendEmailVerification() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendEmailVerification();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}