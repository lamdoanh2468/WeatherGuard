import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';

class LogoutButtonWidget extends StatelessWidget {
  final AuthProvider authProvider;

  const LogoutButtonWidget({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _handleLogout(context),
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text(
        "Đăng xuất tài khoản",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon cảnh báo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                const Text(
                  "Đăng xuất khỏi tài khoản",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Huỷ"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);

                          // Thực hiện đăng xuất
                          await authProvider.signOut();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Đăng xuất tài khoản thành công"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text("Xác nhận"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
