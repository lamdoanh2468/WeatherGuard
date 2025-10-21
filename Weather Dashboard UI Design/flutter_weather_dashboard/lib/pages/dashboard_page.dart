import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    if (provider.loading && provider.weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Lỗi: ${provider.error}'));
    }

    final w = provider.weather;
    final a = provider.airQuality;
    final f = provider.forecast;

    if (w == null) {
      return const Center(child: Text('Chưa có dữ liệu'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshAll(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(w.location, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${w.temperature}°C',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.conditionText),
                  Text('Cảm giác như: ${w.feelsLike}°C'),
                  Text('Độ ẩm: ${w.humidity}%'),
                  Text('Gió: ${w.windSpeed} km/h'),
                  Text('Tầm nhìn: ${w.visibility} km'),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          if (a != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Chất lượng không khí'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('AQI: ${a.aqi} (${a.status})'),
                        Text('PM2.5: ${a.pm25}  PM10: ${a.pm10}')
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text('Dự báo 24h'),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final it = f[i];
                return Container(
                  width: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(it['time']),
                      const SizedBox(height: 8),
                      Text('${it['temp']}°C',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(it['description'] ?? it['condition']),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: f.length,
            ),
          ),
        ],
      ),
    );
  }
}
