import 'package:flutter/material.dart';
import 'package:flutter_weather_dashboard/models/weather_models.dart';
import 'package:flutter_weather_dashboard/services/firebase_service.dart';
import 'package:flutter_weather_dashboard/services/firebase_service.dart';
import 'package:flutter_weather_dashboard/models/weather_models.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giám sát DHT22')),
      body: StreamBuilder<List<WeatherData>>(
        stream: FirebaseService().getWeatherStream().map((dataList) {
          return dataList.map((jsonData) {
            return WeatherData.fromFirebase(jsonData);
          }).toList();
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final latest = data.last;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '⏰ ${latest.dateTime}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                '🌡️ Nhiệt độ: ${latest.temperature.toStringAsFixed(1)}°C',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '💧 Độ ẩm: ${latest.humidity.toStringAsFixed(1)}%',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );
  }
}
