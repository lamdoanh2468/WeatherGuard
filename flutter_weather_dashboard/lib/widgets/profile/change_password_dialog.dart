import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

Future<void> showChangePasswordDialog(BuildContext context) async {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Đổi mật khẩu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PasswordField(
            controller: currentPasswordController,
            label: 'Mật khẩu hiện tại',
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: newPasswordController,
            label: 'Mật khẩu mới',
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: confirmPasswordController,
            label: 'Xác nhận mật khẩu mới',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () async {
            if (newPasswordController.text != confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mật khẩu mới không khớp')),
              );
              return;
            }

            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final success = await authProvider.updatePassword(
              currentPasswordController.text,
              newPasswordController.text,
            );

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Đổi mật khẩu thành công!'
                      : authProvider.errorMessage ?? 'Đổi mật khẩu thất bại'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          },
          child: const Text('Đổi'),
        ),
      ],
    ),
  );

  // Giải phóng controllers (Dispose controllers)
  currentPasswordController.dispose();
  newPasswordController.dispose();
  confirmPasswordController.dispose();
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PasswordField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
