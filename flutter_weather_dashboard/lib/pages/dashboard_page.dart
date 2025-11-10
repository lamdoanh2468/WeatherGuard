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
    context.read<WeatherProvider>().listenToWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    final weatherList = context.watch<WeatherProvider>().weatherList;

    if (weatherList.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final latest = weatherList.last; // bản ghi mới nhất từ Firebase

    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⏰ ${latest['datetime']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('🌡️ Nhiệt độ: ${latest['temperature']}°C',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('💧 Độ ẩm: ${latest['humidity']}%',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
