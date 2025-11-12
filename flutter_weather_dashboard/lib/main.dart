import 'package:flutter/material.dart';
import 'package:flutter_weather_dashboard/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/weather_provider.dart';
import 'providers/theme_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()..init()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const App(),
    ),
  );
}