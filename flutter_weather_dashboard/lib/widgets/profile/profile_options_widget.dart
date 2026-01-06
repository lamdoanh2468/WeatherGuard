import 'package:flutter/material.dart';

class ProfileOptionsWidget extends StatelessWidget {
  final bool showEmailVerification;
  final VoidCallback onChangePassword;
  final VoidCallback onVerifyEmail;

  const ProfileOptionsWidget({
    super.key,
    required this.showEmailVerification,
    required this.onChangePassword,
    required this.onVerifyEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: onChangePassword,
          ),
          if (showEmailVerification) ...[
            const Divider(),
            _buildOptionTile(
              icon: Icons.mark_email_unread,
              title: 'Xác thực email',
              onTap: onVerifyEmail,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5583EE)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
