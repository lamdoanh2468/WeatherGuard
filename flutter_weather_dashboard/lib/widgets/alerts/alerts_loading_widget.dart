import 'package:flutter/material.dart';

class AlertsLoadingWidget extends StatelessWidget {
  final Color accentColor;

  const AlertsLoadingWidget({
    super.key,
    this.accentColor = const Color(0xFFDC2626),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1000),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    color: accentColor,
                    strokeWidth: 3,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
