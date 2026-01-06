/// Trình xác thực biểu mẫu cho xác thực (Auth Validators)
class AuthValidators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!value.contains('@')) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  static String? Function(String?) validateConfirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng xác nhận mật khẩu';
      }
      if (value != password) {
        return 'Mật khẩu không khớp';
      }
      return null;
    };
  }
}
