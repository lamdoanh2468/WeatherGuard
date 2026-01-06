import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsSectionWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsSectionWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final tempMin = double.parse(stats['temperature']['min'].toString());
    final tempMax = double.parse(stats['temperature']['max'].toString());
    final tempAvg = double.parse(stats['temperature']['avg'].toString());

    final humMin = double.parse(stats['humidity']['min'].toString());
    final humMax = double.parse(stats['humidity']['max'].toString());
    final humAvg = double.parse(stats['humidity']['avg'].toString());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
          _buildChartTitle(Icons.thermostat, 'Nhiệt độ (°C)', Colors.orange),
          const SizedBox(height: 12),
          _buildTemperatureChart(tempMin, tempMax, tempAvg),
          const SizedBox(height: 24),
          _buildChartTitle(Icons.water_drop, 'Độ ẩm (%)', Colors.blue),
          const SizedBox(height: 12),
          _buildHumidityChart(humMin, humMax, humAvg),
          const SizedBox(height: 20),
          _buildRecordsInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.bar_chart,
            color: Colors.purple.shade600,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Thống kê',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChartTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureChart(double min, double avg, double max) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: max + 5,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (max + 5) / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.orange.shade200,
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: [
              BarChartGroupData(x: 0, barRods: [
                BarChartRodData(
                  toY: min,
                  color: Colors.orange.shade600,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                )
              ]),
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(
                  toY: avg,
                  color: Colors.orange.shade400,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                )
              ]),
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(
                  toY: max,
                  color: Colors.deepOrange.shade600,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                )
              ]),
            ],
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const style = TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    );
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Thấp', style: style);
                      case 1:
                        return const Text('TB', style: style);
                      case 2:
                        return const Text('Cao', style: style);
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHumidityChart(double min, double avg, double max) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: max + 10,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (max + 10) / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.blue.shade200,
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: [
              BarChartGroupData(x: 0, barRods: [
                BarChartRodData(
                  toY: min,
                  color: Colors.blue.shade600,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                )
              ]),
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(
                  toY: avg,
                  color: Colors.blue.shade400,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                )
              ]),
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(
                  toY: max,
                  color: Colors.cyan.shade600,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                )
              ]),
            ],
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const style = TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    );
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Thấp', style: style);
                      case 1:
                        return const Text('TB', style: style);
                      case 2:
                        return const Text('Cao', style: style);
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.assessment, color: Colors.purple.shade600, size: 20),
          const SizedBox(width: 8),
          Text(
            'Số lượng bản ghi: ${stats['records']}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
