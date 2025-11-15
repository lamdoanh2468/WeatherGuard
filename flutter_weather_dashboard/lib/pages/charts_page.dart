import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  String _selectedView = 'realtime'; // realtime, history

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildViewSelector(),
              const SizedBox(height: 24),
              _selectedView == 'realtime'
                  ? _buildRealtimeView()
                  : _buildHistoryView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Biểu đồ phân tích',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Phân tích xu hướng thời tiết',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.analytics,
              color: Colors.blue.shade600,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildViewButton('realtime', 'Thời gian thực', Icons.timeline),
          _buildViewButton('history', 'Lịch sử', Icons.history),
        ],
      ),
    );
  }

  Widget _buildViewButton(String value, String label, IconData icon) {
    final isSelected = _selectedView == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedView = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeView() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final data = provider.weatherList;

        if (data.isEmpty) {
          return _buildEmptyState();
        }

        final tempPoints = data
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), (e.value['temperature'] as num).toDouble()))
            .toList();

        final humPoints = data
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), (e.value['humidity'] as num).toDouble()))
            .toList();

        return Column(
          children: [
            _buildLineChart(
              title: 'Dự báo 60 phút tới',
              tempPoints: tempPoints,
              humPoints: humPoints,
              showXAxisLabels: true,
              icon: Icons.speed,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            _buildStatCards(data),
          ],
        );
      },
    );
  }

  Widget _buildHistoryView() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final data = provider.weatherList;

        if (data.isEmpty) {
          return _buildEmptyState();
        }

        final tempPoints = data
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), (e.value['temperature'] as num).toDouble()))
            .toList();

        final humPoints = data
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), (e.value['humidity'] as num).toDouble()))
            .toList();

        return Column(
          children: [
            _buildLineChart(
              title: 'Lịch sử ghi nhận',
              tempPoints: tempPoints,
              humPoints: humPoints,
              showXAxisLabels: false,
              icon: Icons.history,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            _buildTrendAnalysis(data),
            const SizedBox(height: 24),
            _buildDistributionChart(data),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.data_usage_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Đang chờ dữ liệu...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart({
    required String title,
    required List<FlSpot> tempPoints,
    required List<FlSpot> humPoints,
    required bool showXAxisLabels,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegendItem(Colors.orange.shade600, 'Nhiệt độ (°C)'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.blue.shade600, 'Độ ẩm (%)'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: showXAxisLabels,
                      reservedSize: 30,
                      interval: showXAxisLabels ? 10 : 1,
                      getTitlesWidget: (value, meta) {
                        if (!showXAxisLabels) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+${value.toInt()}m',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    left: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: tempPoints,
                    isCurved: true,
                    color: Colors.orange.shade600,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.shade100.withOpacity(0.3),
                    ),
                  ),
                  LineChartBarData(
                    spots: humPoints,
                    isCurved: true,
                    color: Colors.blue.shade600,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.shade100.withOpacity(0.3),
                    ),
                  ),
                ],
                lineTouchData: const LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    tooltipRoundedRadius: 8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(List<Map<String, dynamic>> data) {
    final temps =
        data.map((e) => (e['temperature'] as num).toDouble()).toList();
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
          child: _buildStatCard(
            'Nhiệt độ',
            tempMin,
            tempMax,
            tempAvg,
            Colors.orange,
            Icons.thermostat,
            '°C',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Độ ẩm',
            humMin,
            humMax,
            humAvg,
            Colors.blue,
            Icons.water_drop,
            '%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    double min,
    double max,
    double avg,
    MaterialColor color,
    IconData icon,
    String unit,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Min', min, unit, color.shade300),
          const SizedBox(height: 8),
          _buildStatRow('Avg', avg, unit, color.shade500),
          const SizedBox(height: 8),
          _buildStatRow('Max', max, unit, color.shade700),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
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

  Widget _buildTrendAnalysis(List<Map<String, dynamic>> data) {
    if (data.length < 2) {
      return const SizedBox();
    }

    final temps =
        data.map((e) => (e['temperature'] as num).toDouble()).toList();
    final hums = data.map((e) => (e['humidity'] as num).toDouble()).toList();

    final tempTrend = _calculateTrend(temps);
    final humTrend = _calculateTrend(hums);

    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Colors.amber.shade700,
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
          ),
          const SizedBox(height: 20),
          _buildTrendCard(
              'Nhiệt độ', tempTrend, Icons.thermostat, Colors.orange),
          const SizedBox(height: 12),
          _buildTrendCard('Độ ẩm', humTrend, Icons.water_drop, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    String label,
    String trend,
    IconData icon,
    MaterialColor color,
  ) {
    IconData trendIcon;
    Color trendColor;
    if (trend.contains('Tăng')) {
      trendIcon = Icons.trending_up;
      trendColor = Colors.red;
    } else if (trend.contains('Giảm')) {
      trendIcon = Icons.trending_down;
      trendColor = Colors.green;
    } else {
      trendIcon = Icons.trending_flat;
      trendColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
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
            ),
            child: Icon(icon, color: color, size: 24),
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
                    color: color.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(trendIcon, color: trendColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(List<Map<String, dynamic>> data) {
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

    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: Colors.green.shade600,
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
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _getPieSections(tempRanges),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: tempRanges.entries.map((e) {
              return _buildPieLegend(e.key, e.value, data.length);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPieLegend(String label, int count, int total) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $percentage%',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
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
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

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
}
