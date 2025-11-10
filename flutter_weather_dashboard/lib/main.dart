import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'providers/weather_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Nếu dùng Firebase

  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: const App(),
    ),
  );
}