import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  // Các Getter
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initAuthListener();
  }

  // Khởi tạo trình lắng nghe trạng thái xác thực
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

  // Tải dữ liệu người dùng từ Firestore
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

  // Đăng ký
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

  // Đăng nhập
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

  // Đăng xuất
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

  // Đặt lại mật khẩu
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

  // Cập nhật hồ sơ
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
        // Cập nhật tên hiển thị trong Firebase Auth
        if (name != null) {
          await _authService.updateProfile(displayName: name);
        }

        // Cập nhật dữ liệu người dùng trong Firestore
        await _authService.updateUserData(
          uid: _user!.uid,
          name: name,
          phone: phone,
          address: address,
        );

        // Tải lại dữ liệu người dùng
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

  // Cập nhật Email
  Future<bool> updateEmail(String newEmail, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Xác thực lại người dùng trước
      await _authService.reauthenticateUser(password);

      // Cập nhật email
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

  // Cập nhật Mật khẩu
  Future<bool> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Xác thực lại người dùng trước
      await _authService.reauthenticateUser(currentPassword);

      // Cập nhật mật khẩu
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

  // Xóa tài khoản
  Future<bool> deleteAccount(String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Xác thực lại người dùng trước
      await _authService.reauthenticateUser(password);

      // Xóa tài khoản
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

  // Gửi email xác thực
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

  // Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
