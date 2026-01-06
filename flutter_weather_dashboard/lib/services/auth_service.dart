import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy người dùng hiện tại
  User? get currentUser => _auth.currentUser;

  // Luồng thay đổi trạng thái xác thực
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Kiểm tra người dùng đã đăng nhập chưa
  bool get isLoggedIn => _auth.currentUser != null;

  // Đăng ký với Email và Mật khẩu
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Tạo người dùng trong Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật tên hiển thị
      await userCredential.user?.updateDisplayName(name);

      // Tạo tài liệu người dùng trong Firestore
      await _createUserDocument(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      return userCredential;
    } on FirebaseException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi: $e';
    }
  }

  // Đăng nhập với Email và Mật khẩu
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi: $e';
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Không thể đăng xuất: $e';
    }
  }

  // Đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi: $e';
    }
  }

  // Cập nhật hồ sơ người dùng
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();
      }
    } catch (e) {
      throw 'Không thể cập nhật hồ sơ: $e';
    }
  }

  // Cập nhật Email
  Future<void> updateEmail(String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.reload();
      }
    } on FirebaseException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Không thể cập nhật email: $e';
    }
  }

  // Cập nhật Mật khẩu
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } on FirebaseException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Không thể cập nhật mật khẩu: $e';
    }
  }

  // Xác thực lại người dùng (cần thiết trước các thao tác nhạy cảm)
  Future<void> reauthenticateUser(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Xác thực không thành công: $e';
    }
  }

  // Xóa tài khoản
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Xóa tài liệu người dùng khỏi Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Xóa người dùng khỏi Firebase Auth
        await user.delete();
      }
    } on FirebaseException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Không thể xóa tài khoản: $e';
    }
  }

  // Tạo tài liệu người dùng trong Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'phone': '',
        'address': '',
        'photoURL': '',
      });
    } catch (e) {
      throw 'Không thể tạo hồ sơ người dùng: $e';
    }
  }

  // Lấy dữ liệu người dùng từ Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw 'Không thể tải dữ liệu người dùng: $e';
    }
  }

  // Cập nhật dữ liệu người dùng trong Firestore
  Future<void> updateUserData({
    required String uid,
    String? name,
    String? phone,
    String? address,
    String? photoURL,
  }) async {
    try {
      Map<String, dynamic> data = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (photoURL != null) data['photoURL'] = photoURL;

      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Không thể cập nhật dữ liệu: $e';
    }
  }

  // Xử lý các ngoại lệ Firebase Auth
  String _handleAuthException(FirebaseException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Thao tác này không được phép.';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để thực hiện thao tác này.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      default:
        return 'Đã xảy ra lỗi: ${e.message ?? e.code}';
    }
  }

  // Gửi email xác thực
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw 'Không thể gửi email xác thực: $e';
    }
  }

  // Kiểm tra email đã được xác thực chưa
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }
}
