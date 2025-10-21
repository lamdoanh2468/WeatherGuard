import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class ApiKeySetupPage extends StatefulWidget {
  const ApiKeySetupPage({super.key});

  @override
  State<ApiKeySetupPage> createState() => _ApiKeySetupPageState();
}

class _ApiKeySetupPageState extends State<ApiKeySetupPage> {
  final _owController = TextEditingController();
  final _aqiController = TextEditingController();

  @override
  void dispose() {
    _owController.dispose();
    _aqiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt API Keys')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _owController,
              decoration: const InputDecoration(
                  labelText: 'OpenWeatherMap API Key',
                  hintText: 'Nhập API key...'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aqiController,
              decoration: const InputDecoration(
                  labelText: 'AQICN API Key', hintText: 'Nhập API key...'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                await context.read<WeatherProvider>().saveApiKeys(
                      openWeather: _owController.text.isEmpty
                          ? null
                          : _owController.text,
                      aqicn: _aqiController.text.isEmpty
                          ? null
                          : _aqiController.text,
                    );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text('Lưu'),
            )
          ],
        ),
      ),
    );
  }
}
