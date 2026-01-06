import 'package:flutter/material.dart';

class TrendAnalysisWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const TrendAnalysisWidget({
    super.key,
    required this.data,
  });

  String _calculateTrend(List<double> values) {
    if (values.length < 2) return 'Không đủ dữ liệu';

    final first = values.sublist(0, values.length ~/ 2);
    final second = values.sublist(values.length ~/ 2);

    final avgFirst = first.reduce((a, b) => a + b) / first.length;
    final avgSecond = second.reduce((a, b) => a + b) / second.length;

    final diff = avgSecond - avgFirst;

    if (diff > 1) {
      return 'Tăng (+${diff.toStringAsFixed(1)})';
    } else if (diff < -1) {
      return 'Giảm (${diff.toStringAsFixed(1)})';
    } else {
      return 'Ổn định';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return const SizedBox();
    }

    final temps = data.map((e) => (e['temperature'] as num).toDouble()).toList();
    final hums = data.map((e) => (e['humidity'] as num).toDouble()).toList();

    final tempTrend = _calculateTrend(temps);
    final humTrend = _calculateTrend(hums);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _TrendCard(
                    label: 'Nhiệt độ',
                    trend: tempTrend,
                    icon: Icons.thermostat_outlined,
                    color: Colors.orange,
                    delay: 0,
                  ),
                  const SizedBox(height: 12),
                  _TrendCard(
                    label: 'Độ ẩm',
                    trend: humTrend,
                    icon: Icons.water_drop_outlined,
                    color: Colors.blue,
                    delay: 100,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade400, Colors.amber.shade700],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.trending_up_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Phân tích xu hướng',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String label;
  final String trend;
  final IconData icon;
  final MaterialColor color;
  final int delay;

  const _TrendCard({
    required this.label,
    required this.trend,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    IconData trendIcon;
    Color trendColor;
    if (trend.contains('Tăng')) {
      trendIcon = Icons.trending_up_rounded;
      trendColor = Colors.red.shade600;
    } else if (trend.contains('Giảm')) {
      trendIcon = Icons.trending_down_rounded;
      trendColor = Colors.green.shade600;
    } else {
      trendIcon = Icons.trending_flat_rounded;
      trendColor = Colors.grey.shade600;
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.shade50,
                    color.shade50.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color.shade600, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            color: color.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: trendColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                trendIcon,
                                color: trendColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              trend,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
