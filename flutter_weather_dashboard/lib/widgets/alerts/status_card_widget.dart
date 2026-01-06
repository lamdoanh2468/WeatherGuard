import 'package:flutter/material.dart';

class StatusCardWidget extends StatelessWidget {
  final String? level;
  final Animation<double> pulseAnimation;

  const StatusCardWidget({
    super.key,
    required this.level,
    required this.pulseAnimation,
  });

  Color _getStatusColor(String? level) {
    switch (level) {
      case 'danger':
        return const Color(0xFFDC2626);
      case 'warning':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  IconData _getStatusIcon(String? level) {
    switch (level) {
      case 'danger':
        return Icons.warning_amber_rounded;
      case 'warning':
        return Icons.info_outline_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _getStatusText(String? level) {
    switch (level) {
      case 'danger':
        return "NGUY HIỂM";
      case 'warning':
        return "CẢNH BÁO";
      default:
        return "AN TOÀN";
    }
  }

  String _getStatusDescription(String? level) {
    switch (level) {
      case 'danger':
        return "Chỉ số vượt ngưỡng nguy hiểm, xử lý ngay!";
      case 'warning':
        return "Phát hiện bất thường, cần theo dõi";
      default:
        return "Nhiệt độ & độ ẩm trong ngưỡng an toàn";
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(level);
    final icon = _getStatusIcon(level);
    final text = _getStatusText(level);
    final description = _getStatusDescription(level);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.85), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    final shouldPulse = level == 'danger';
                    return Transform.scale(
                      scale: shouldPulse ? pulseAnimation.value : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 48),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
