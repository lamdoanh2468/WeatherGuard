import 'package:flutter/material.dart';

/// Hiển thị hộp thoại xác nhận trước khi xóa trạm (Shows a confirmation dialog before deleting a station)
void showDeleteConfirmationDialog(
    BuildContext context, Map<String, dynamic> station) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Xóa trạm giám sát?'),
        content: Text(
          'Bạn có chắc muốn xóa trạm "${station['name']}"? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Trạm này lấy dữ liệu từ Firebase, không thể xóa từ app'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      );
    },
  );
}
