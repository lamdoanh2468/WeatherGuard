import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final f = provider.forecast;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFFE0F7FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    color: Colors.blueGrey, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Biểu đồ thời tiết',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: f.isEmpty
                  ? const Center(
                      child: Text(
                        '⛅ Chưa có dữ liệu, vui lòng chờ cập nhật...',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: f.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final it = f[i];
                        final temp = (it['temp'] as num).toDouble();

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.wb_sunny_rounded,
                                      color: Colors.orangeAccent),
                                  Text(it['time'],
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: temp / 50.0,
                                    minHeight: 14,
                                    backgroundColor: Colors.blueGrey[100],
                                    valueColor: AlwaysStoppedAnimation(
                                      temp > 30
                                          ? Colors.redAccent
                                          : (temp > 20
                                              ? Colors.orangeAccent
                                              : Colors.lightBlueAccent),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${temp.toStringAsFixed(1)}°C',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: temp > 30
                                      ? Colors.redAccent
                                      : (temp > 20
                                          ? Colors.orangeAccent
                                          : Colors.lightBlueAccent),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
