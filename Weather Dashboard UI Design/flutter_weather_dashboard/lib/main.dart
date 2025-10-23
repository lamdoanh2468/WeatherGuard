import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/weather_provider.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: '.env').catchError((_) => null);
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => WeatherProvider()..init(), //Manage Weather Data
//       child: const App(),
//     ),
//   );
// }
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Xóa .catchError((_) => null)
  // Thêm try-catch để in lỗi thật ra console
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('!!!!!!!!!!!!!! LỖI KHI LOAD .env !!!!!!!!!!!!!!');
    print(e); // Lỗi thật sẽ in ở đây
    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider()..init(),
      child: const App(),
    ),
  );
}
