import 'package:flutter/material.dart';
import 'package:flutter_weather_dashboard/auth/login_page.dart';
import 'package:flutter_weather_dashboard/auth/profile_page.dart';
import 'package:flutter_weather_dashboard/auth/register_page.dart';
import 'package:flutter_weather_dashboard/stations/my_station.dart';
import 'package:flutter_weather_dashboard/firebase_options.dart';
import 'package:flutter_weather_dashboard/pages/account_page.dart';
import 'package:flutter_weather_dashboard/providers/alert_provider.dart';
import 'package:flutter_weather_dashboard/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/weather_provider.dart';
import 'providers/theme_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'WeatherGuard',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          initialRoute: '/',
          routes: {
            '/': (context) => const App(),
            '/account': (context) => const AccountPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/profile': (context) => const ProfilePage(),
            '/my-station': (context) => const MyStationPage()
          },
        );
      },
    );
  }
}