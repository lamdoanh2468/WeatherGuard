import 'package:flutter/material.dart';

class AlertsHeaderWidget extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final String? statusLevel;
  final Color Function(String?) getStatusColor;

  const AlertsHeaderWidget({
    super.key,
    required this.pulseAnimation,
    required this.statusLevel,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giám Sát Môi Trường',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Theo dõi nhiệt độ & độ ẩm thời gian thực',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              final level = statusLevel ?? 'normal';
              final shouldPulse = level == 'danger' || level == 'warning';

              return Transform.scale(
                scale: shouldPulse ? pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: shouldPulse
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: getStatusColor(level),
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
