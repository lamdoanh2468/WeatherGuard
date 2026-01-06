import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';

class UserInfoWidget extends StatelessWidget {
  final AuthProvider authProvider;

  const UserInfoWidget({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    final user = authProvider.user!;
    final displayName = user.displayName ?? user.email ?? 'User';
    final email = user.email ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hình đại diện (Avatar)
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5583EE), Color(0xFF4961DC)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Thông tin người dùng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Chỉnh sửa thông tin cá nhân'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
