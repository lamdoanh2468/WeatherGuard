import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/weather_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // Tạo provider và khởi tạo trước khi chạy app
  final weatherProvider = WeatherProvider();
  await weatherProvider.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => weatherProvider,
      child: const App(),
    ),
  );
}
