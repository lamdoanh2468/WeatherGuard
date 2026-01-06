import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/stat_cards_widget.dart';
import '../widgets/charts/trend_analysis_widget.dart';
import '../widgets/charts/distribution_chart_widget.dart';
import '../widgets/charts/view_selector_widget.dart';
import '../widgets/charts/charts_header_widget.dart';
import '../widgets/charts/charts_empty_state_widget.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> with TickerProviderStateMixin {
  String _selectedView = 'realtime';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onViewChanged(String newView) {
    if (_selectedView != newView) {
      setState(() => _selectedView = newView);
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ChartsHeaderWidget(),
              const SizedBox(height: 20),
              ViewSelectorWidget(
                selectedView: _selectedView,
                onViewChanged: _onViewChanged,
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _selectedView == 'realtime'
                      ? _buildRealtimeView()
                      : _buildHistoryView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeView() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final data = provider.weatherList;

        if (data.isEmpty) {
          return const ChartsEmptyStateWidget();
        }

        final tempPoints = data
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), (e.value['temperature'] as num).toDouble()))
            .toList();

        final humPoints = data
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), (e.value['humidity'] as num).toDouble()))
            .toList();

        return Column(
          children: [
            LineChartWidget(
              title: 'Dự báo 60 phút tới',
              tempPoints: tempPoints,
              humPoints: humPoints,
              showXAxisLabels: true,
              icon: Icons.speed_rounded,
              color: Colors.green,
              delay: 0,
            ),
            const SizedBox(height: 24),
            StatCardsWidget(data: data),
          ],
        );
      },
    );
  }

  List<FlSpot> _calculateTrendLine(List<FlSpot> data) {
    if (data.length < 2) return [];

    double n = data.length.toDouble();
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumXX = 0;

    for (var spot in data) {
      sumX += spot.x;
      sumY += spot.y;
      sumXY += spot.x * spot.y;
      sumXX += spot.x * spot.x;
    }

    double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;

    // Create just two points for the trend line: start and end
    final startX = data.first.x;
    final endX = data.last.x;

    return [
      FlSpot(startX, slope * startX + intercept),
      FlSpot(endX, slope * endX + intercept),
    ];
  }

  Widget _buildHistoryView() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final data = provider.weatherList;

        if (data.isEmpty) {
          return const ChartsEmptyStateWidget();
        }

        final tempPoints = data
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), (e.value['temperature'] as num).toDouble()))
            .toList();

        final humPoints = data
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), (e.value['humidity'] as num).toDouble()))
            .toList();

        final trendPoints = _calculateTrendLine(tempPoints);

        return Column(
          children: [
            LineChartWidget(
              title: 'Lịch sử ghi nhận',
              tempPoints: tempPoints,
              humPoints: humPoints,
              trendPoints: trendPoints,
              showXAxisLabels: false,
              icon: Icons.history_rounded,
              color: Colors.purple,
              delay: 0,
            ),
            const SizedBox(height: 24),
            TrendAnalysisWidget(data: data),
            const SizedBox(height: 24),
            DistributionChartWidget(data: data),
          ],
        );
      },
    );
  }
}
