import 'package:flutter/material.dart';

class NotLoggedInWidget extends StatelessWidget {
  const NotLoggedInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_off,
            size: 80,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa đăng nhập',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5583EE),
            ),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}
