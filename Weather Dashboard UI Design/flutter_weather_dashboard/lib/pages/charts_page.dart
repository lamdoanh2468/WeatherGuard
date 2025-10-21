import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final f = provider.forecast;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Biểu đồ (đơn giản)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: f.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final it = f[i];
                return Row(
                  children: [
                    SizedBox(width: 60, child: Text(it['time'])),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (it['temp'] as num) / 50.0,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${it['temp']}°C'),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
