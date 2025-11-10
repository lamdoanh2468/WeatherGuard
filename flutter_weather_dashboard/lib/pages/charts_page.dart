import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather_dashboard/models/weather_models.dart';
import 'package:flutter_weather_dashboard/services/firebase_service.dart';
import 'package:flutter_weather_dashboard/services/firebase_service.dart';
import 'package:flutter_weather_dashboard/models/weather_models.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biểu đồ DHT22')),
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
          final tempPoints = data
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.temperature))
              .toList();

          final humPoints = data
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.humidity))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                      spots: tempPoints, isCurved: true, barWidth: 2),
                  LineChartBarData(
                      spots: humPoints, isCurved: true, barWidth: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
