import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/weather_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    Future.microtask(() {
      context.read<WeatherProvider>().loadLatest();
      context.read<WeatherProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final latest = context.watch<WeatherProvider>().latest;
    if (latest == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                'Đang tải dữ liệu...',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    final weatherList = context.watch<WeatherProvider>().weatherList;

    if (weatherList.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                'Đang tải dữ liệu...',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildTimeCard(latest['datetime']),
              const SizedBox(height: 20),

              // Main Weather Cards
              Row(
                children: [
                  Expanded(
                    child: _buildWeatherCard(
                      icon: '🌡️',
                      label: 'Nhiệt độ',
                      value: '${latest['temperature']}°C',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWeatherCard(
                      icon: '💧',
                      label: 'Độ ẩm',
                      value: '${latest['humidity']}%',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildHistorySection(weatherList),
              const SizedBox(height: 20),
              // Stats Section
              Consumer<WeatherProvider>(
                builder: (context, provider, child) {
                  final stats = provider.stats;
                  if (stats == null) return const SizedBox();
                  return _buildStatsSection(stats);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String datetime) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Cập nhật lần cuối',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(datetime),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List<Map<String, dynamic>> weatherList) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử đo',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...weatherList.take(5).map((data) => _buildHistoryItem(data)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDateTime(data['datetime']),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '🌡️ ${data['temperature']}°C',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '💧 ${data['humidity']}%',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    // Chuyển dữ liệu sang double để chart
    final tempMin = double.parse(stats['temperature']['min'].toString());
    final tempMax = double.parse(stats['temperature']['max'].toString());
    final tempAvg = double.parse(stats['temperature']['avg'].toString());

    final humMin = double.parse(stats['humidity']['min'].toString());
    final humMax = double.parse(stats['humidity']['max'].toString());
    final humAvg = double.parse(stats['humidity']['avg'].toString());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Biểu đồ nhiệt độ
          const Text('🌡️ Nhiệt độ (°C)', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: tempMax + 5,
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: tempMin, color: Colors.orange)
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: tempAvg, color: Colors.orangeAccent)
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: tempMax, color: Colors.deepOrange)
                  ]),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Min');
                          case 1:
                            return const Text('Avg');
                          case 2:
                            return const Text('Max');
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Biểu đồ độ ẩm
          const Text('💧 Độ ẩm (%)', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: humMax + 10,
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: humMin, color: Colors.blue)
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: humAvg, color: Colors.lightBlue)
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: humMax, color: Colors.blueAccent)
                  ]),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Min');
                          case 1:
                            return const Text('Avg');
                          case 2:
                            return const Text('Max');
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Text('Số lượng bản ghi: ${stats['records']}',
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  String _formatDateTime(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return datetime;
    }
  }
}
