import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DistributionChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const DistributionChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final tempRanges = <String, int>{
      '<20°C': 0,
      '20-25°C': 0,
      '25-30°C': 0,
      '30-35°C': 0,
      '>35°C': 0,
    };

    for (var item in data) {
      final temp = (item['temperature'] as num).toDouble();
      if (temp < 20) {
        tempRanges['<20°C'] = tempRanges['<20°C']! + 1;
      } else if (temp < 25) {
        tempRanges['20-25°C'] = tempRanges['20-25°C']! + 1;
      } else if (temp < 30) {
        tempRanges['25-30°C'] = tempRanges['25-30°C']! + 1;
      } else if (temp < 35) {
        tempRanges['30-35°C'] = tempRanges['30-35°C']! + 1;
      } else {
        tempRanges['>35°C'] = tempRanges['>35°C']! + 1;
      }
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
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
                  const SizedBox(height: 24),
                  _buildPieChart(tempRanges),
                  const SizedBox(height: 20),
                  _buildLegend(tempRanges),
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
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.pie_chart_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Phân phối nhiệt độ',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(Map<String, int> tempRanges) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _getPieSections(tempRanges),
          sectionsSpace: 3,
          centerSpaceRadius: 55,
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {},
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, int> tempRanges) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: tempRanges.entries.map((e) {
        return _buildPieLegend(e.key, e.value, data.length);
      }).toList(),
    );
  }

  Widget _buildPieLegend(String label, int count, int total) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        '$label: $percentage%',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections(Map<String, int> data) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.yellow.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
    ];

    return data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: item.value.toDouble(),
        title: '${item.value}',
        radius: 65,
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: item.value > 0 ? null : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }
}
