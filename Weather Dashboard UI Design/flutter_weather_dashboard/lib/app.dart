import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/account_page.dart';
import 'pages/alerts_page.dart';
import 'pages/api_key_setup_page.dart';
import 'pages/charts_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/maps_page.dart';
import 'providers/weather_provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _index = 0;

  final _pages = const [
    DashboardPage(),
    ChartsPage(),
    MapsPage(),
    AlertsPage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      routes: {
        '/api-keys': (_) => const ApiKeySetupPage(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Weather Dashboard'),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/api-keys'),
              icon: const Icon(Icons.vpn_key),
              tooltip: 'Cài đặt API',
            ),
          ],
        ),
        body: _pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Tổng quan'),
            NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: 'Biểu đồ'),
            NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Bản đồ'),
            NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Cảnh báo'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }
}
