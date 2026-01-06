import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/account_page.dart';
import 'pages/alerts_page.dart';
import 'pages/charts_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/maps_page.dart';
import 'providers/theme_provider.dart';

import 'package:flutter_weather_dashboard/providers/navigation_provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _pages = const [
    DashboardPage(),
    ChartsPage(),
    MapsPage(),
    AlertsPage(),
    AccountPage(),
  ];

  final _titles = const [
    'Tổng Quan Thời Tiết',
    'Biểu Đồ & Phân Tích',
    'Bản Đồ',
    'Thông Báo & Cảnh Báo',
    'Tài Khoản',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final currentIndex = navigationProvider.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
        actions: [
          // Nút chuyển đổi giao diện (Toggle Theme Button)
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
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(themeProvider.isDarkMode),
                color: themeProvider.isDarkMode ? Colors.amber : Colors.indigo,
                size: 24,
              ),
            ),
            tooltip: themeProvider.isDarkMode ? 'Chế độ sáng' : 'Chế độ tối',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => navigationProvider.setIndex(i),
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
