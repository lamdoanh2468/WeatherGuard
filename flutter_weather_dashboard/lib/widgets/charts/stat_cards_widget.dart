import 'package:flutter/material.dart';

class StatCardsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const StatCardsWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final temps = data.map((e) => (e['temperature'] as num).toDouble()).toList();
    final hums = data.map((e) => (e['humidity'] as num).toDouble()).toList();

    final tempMin = temps.reduce((a, b) => a < b ? a : b);
    final tempMax = temps.reduce((a, b) => a > b ? a : b);
    final tempAvg = temps.reduce((a, b) => a + b) / temps.length;

    final humMin = hums.reduce((a, b) => a < b ? a : b);
    final humMax = hums.reduce((a, b) => a > b ? a : b);
    final humAvg = hums.reduce((a, b) => a + b) / hums.length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Nhiệt độ',
            min: tempMin,
            max: tempMax,
            avg: tempAvg,
            color: Colors.orange,
            icon: Icons.thermostat_outlined,
            unit: '°C',
            delay: 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Độ ẩm',
            min: humMin,
            max: humMax,
            avg: humAvg,
            color: Colors.blue,
            icon: Icons.water_drop_outlined,
            unit: '%',
            delay: 100,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double min;
  final double max;
  final double avg;
  final MaterialColor color;
  final IconData icon;
  final String unit;
  final int delay;

  const _StatCard({
    required this.title,
    required this.min,
    required this.max,
    required this.avg,
    required this.color,
    required this.icon,
    required this.unit,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.12),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color.shade600, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _StatRow(label: 'Thấp nhất', value: min, unit: unit, color: color.shade400),
                const SizedBox(height: 8),
                _StatRow(label: 'Trung bình', value: avg, unit: unit, color: color.shade600),
                const SizedBox(height: 8),
                _StatRow(label: 'Cao nhất', value: max, unit: unit, color: color.shade800),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
