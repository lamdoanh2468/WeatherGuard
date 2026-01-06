import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/weather_provider.dart';
import '../widgets/dashboard/weather_card_widget.dart';
import '../widgets/dashboard/time_card_widget.dart';
import '../widgets/dashboard/history_section_widget.dart';
import '../widgets/dashboard/stats_section_widget.dart';

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
      return _buildLoadingState();
    }
    final weatherList = context.watch<WeatherProvider>().weatherList;

    if (weatherList.isEmpty) {
      return _buildLoadingState();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              TimeCardWidget(datetime: latest['datetime']),
              const SizedBox(height: 20),

              // Thẻ thời tiết chính (Main Weather Cards)
              Row(
                children: [
                  Expanded(
                    child: WeatherCardWidget(
                      icon: Icons.thermostat,
                      label: 'Nhiệt độ',
                      value: '${latest['temperature']}°C',
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.deepOrange.shade500
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: WeatherCardWidget(
                      icon: Icons.water_drop,
                      label: 'Độ ẩm',
                      value: '${latest['humidity']}%',
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.cyan.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              HistorySectionWidget(weatherList: weatherList),
              const SizedBox(height: 24),

              // Phần thống kê (Stats Section)
              Consumer<WeatherProvider>(
                builder: (context, provider, child) {
                  final stats = provider.stats;
                  if (stats == null) return const SizedBox();
                  return StatsSectionWidget(stats: stats);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
                'Tổng quan dữ liệu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Theo dõi thời tiết',
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
              Icons.cloud,
              color: Colors.blue.shade600,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
