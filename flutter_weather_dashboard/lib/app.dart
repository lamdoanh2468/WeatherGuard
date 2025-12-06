import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/account_page.dart';
import 'pages/alerts_page.dart';
import 'pages/charts_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/maps_page.dart';
import 'providers/theme_provider.dart';

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

  final _titles = const [
    'Weather Dashboard',
    'Charts & Insight',
    'Maps',
    'Notifications & Alerts',
    'User Account',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          // Toggle Theme Button
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
                key: ValueKey(themeProvider.isDarkMode),
                color: themeProvider.isDarkMode
                    ? Colors.amber
                    : Colors.indigo,
                size: 24,
              ),
            ),
            tooltip: themeProvider.isDarkMode
                ? 'Chế độ sáng'
                : 'Chế độ tối',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Biểu đồ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Bản đồ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Cảnh báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}