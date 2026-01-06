import 'package:flutter/material.dart';

class StationEmptyStateWidget extends StatelessWidget {
  final VoidCallback? onAddStation;

  const StationEmptyStateWidget({
    super.key,
    this.onAddStation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sensors_off,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có trạm giám sát',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Thêm trạm đầu tiên để bắt đầu\ngiám sát thời tiết',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onAddStation ?? () {
              Navigator.pushNamed(context, '/add-station');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5583EE),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Thêm trạm mới'),
          ),
        ],
      ),
    );
  }
}
