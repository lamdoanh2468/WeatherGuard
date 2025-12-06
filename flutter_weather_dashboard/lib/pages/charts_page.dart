import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildViewSelector(),
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

  Widget _buildHeader() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân Tích Dữ Liệu',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Biểu đồ & xu hướng nhiệt độ - độ ẩm',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewSelector() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildViewButton(
                    'realtime', 'Dữ liệu thời gian thực ', Icons.timeline),
                _buildViewButton(
                    'history', 'Lịch sử thu thập', Icons.history_rounded),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewButton(String value, String label, IconData icon) {
    final isSelected = _selectedView == value;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onViewChanged(value),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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
          return _buildEmptyState();
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
            _buildLineChart(
              title: 'Dự báo 60 phút tới',
              tempPoints: tempPoints,
              humPoints: humPoints,
              showXAxisLabels: true,
              icon: Icons.speed_rounded,
              color: Colors.green,
              delay: 0,
            ),
            const SizedBox(height: 24),
            _buildStatCards(data),
          ],
        );
      },
    );
  }

  Widget _buildHistoryView() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final data = provider.weatherList;

        if (data.isEmpty) {
          return _buildEmptyState();
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
            _buildLineChart(
              title: 'Lịch sử ghi nhận',
              tempPoints: tempPoints,
              humPoints: humPoints,
              showXAxisLabels: false,
              icon: Icons.history_rounded,
              color: Colors.purple,
              delay: 0,
            ),
            const SizedBox(height: 24),
            _buildTrendAnalysis(data),
            const SizedBox(height: 24),
            _buildDistributionChart(data),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(64),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.data_usage_outlined,
                      size: 64,
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Đang chờ dữ liệu...',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dữ liệu sẽ xuất hiện khi có bản ghi mới',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLineChart({
    required String title,
    required List<FlSpot> tempPoints,
    required List<FlSpot> humPoints,
    required bool showXAxisLabels,
    required IconData icon,
    required MaterialColor color,
    required int delay,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.shade400, color.shade600],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildLegendItem(Colors.orange.shade600, 'Nhiệt độ (°C)'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.blue.shade600, 'Độ ẩm (%)'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 10,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: showXAxisLabels,
                              reservedSize: 30,
                              interval: showXAxisLabels ? 10 : 1,
                              getTitlesWidget: (value, meta) {
                                if (!showXAxisLabels) return const Text('');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '+${value.toInt()}m',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                            left: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: tempPoints,
                            isCurved: true,
                            color: Colors.orange.shade600,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade200.withValues(alpha: 0.3),
                                  Colors.orange.shade50.withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          LineChartBarData(
                            spots: humPoints,
                            isCurved: true,
                            color: Colors.blue.shade600,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade200.withValues(alpha: 0.3),
                                  Colors.blue.shade50.withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: const LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.black87,
                            tooltipRoundedRadius: 8,
                            tooltipPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCards(List<Map<String, dynamic>> data) {
    final temps =
        data.map((e) => (e['temperature'] as num).toDouble()).toList();
    final hums = data.map((e) => (e['humidity'] as num).toDouble()).toList();

    final tempMin = temps.reduce((a, b) => a < b ? a : b);
    final tempMax = temps.reduce((a, b) => a > b ? a : b);
    final tempAvg = temps.reduce((a, b) => a + b) / temps.length;

    final humMin = hums.reduce((a, b) => a < b ? a : b);
    final humMax = hums.reduce((a, b) => a > b ? a : b);
    final humAvg = hums.reduce((a, b) => a + b) / hums.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Nhiệt độ',
            tempMin,
            tempMax,
            tempAvg,
            Colors.orange,
            Icons.thermostat_outlined,
            '°C',
            0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Độ ẩm',
            humMin,
            humMax,
            humAvg,
            Colors.blue,
            Icons.water_drop_outlined,
            '%',
            100,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    double min,
    double max,
    double avg,
    MaterialColor color,
    IconData icon,
    String unit,
    int delay,
  ) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.12),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color.shade600, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow('Thấp nhất', min, unit, color.shade400),
                const SizedBox(height: 8),
                _buildStatRow('Trung bình', avg, unit, color.shade600),
                const SizedBox(height: 8),
                _buildStatRow('Cao nhất', max, unit, color.shade800),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, double value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendAnalysis(List<Map<String, dynamic>> data) {
    if (data.length < 2) {
      return const SizedBox();
    }

    final temps =
        data.map((e) => (e['temperature'] as num).toDouble()).toList();
    final hums = data.map((e) => (e['humidity'] as num).toDouble()).toList();

    final tempTrend = _calculateTrend(temps);
    final humTrend = _calculateTrend(hums);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.amber.shade700
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Phân tích xu hướng',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTrendCard(
                    'Nhiệt độ',
                    tempTrend,
                    Icons.thermostat_outlined,
                    Colors.orange,
                    0,
                  ),
                  const SizedBox(height: 12),
                  _buildTrendCard(
                    'Độ ẩm',
                    humTrend,
                    Icons.water_drop_outlined,
                    Colors.blue,
                    100,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendCard(
    String label,
    String trend,
    IconData icon,
    MaterialColor color,
    int delay,
  ) {
    IconData trendIcon;
    Color trendColor;
    if (trend.contains('Tăng')) {
      trendIcon = Icons.trending_up_rounded;
      trendColor = Colors.red.shade600;
    } else if (trend.contains('Giảm')) {
      trendIcon = Icons.trending_down_rounded;
      trendColor = Colors.green.shade600;
    } else {
      trendIcon = Icons.trending_flat_rounded;
      trendColor = Colors.grey.shade600;
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.shade50,
                    color.shade50.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color.shade600, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            color: color.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: trendColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                trendIcon,
                                color: trendColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              trend,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDistributionChart(List<Map<String, dynamic>> data) {
    final tempRanges = <String, int>{
      '<20°C': 0,
      '20-25°C': 0,
      '25-30°C': 0,
      '30-35°C': 0,
      '>35°C': 0,
    };

    for (var item in data) {
      final temp = (item['temperature'] as num).toDouble();
      if (temp < 20) {
        tempRanges['<20°C'] = tempRanges['<20°C']! + 1;
      } else if (temp < 25) {
        tempRanges['20-25°C'] = tempRanges['20-25°C']! + 1;
      } else if (temp < 30) {
        tempRanges['25-30°C'] = tempRanges['25-30°C']! + 1;
      } else if (temp < 35) {
        tempRanges['30-35°C'] = tempRanges['30-35°C']! + 1;
      } else {
        tempRanges['>35°C'] = tempRanges['>35°C']! + 1;
      }
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pie_chart_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Phân phối nhiệt độ',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _getPieSections(tempRanges),
                        sectionsSpace: 3,
                        centerSpaceRadius: 55,
                        borderData: FlBorderData(show: false),
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: tempRanges.entries.map((e) {
                      return _buildPieLegend(e.key, e.value, data.length);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPieLegend(String label, int count, int total) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        '$label: $percentage%',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections(Map<String, int> data) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.yellow.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
    ];

    return data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: item.value.toDouble(),
        title: '${item.value}',
        radius: 65,
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: item.value > 0 ? null : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  String _calculateTrend(List<double> values) {
    if (values.length < 2) return 'Không đủ dữ liệu';

    final first = values.sublist(0, values.length ~/ 2);
    final second = values.sublist(values.length ~/ 2);

    final avgFirst = first.reduce((a, b) => a + b) / first.length;
    final avgSecond = second.reduce((a, b) => a + b) / second.length;

    final diff = avgSecond - avgFirst;

    if (diff > 1) {
      return 'Tăng (+${diff.toStringAsFixed(1)})';
    } else if (diff < -1) {
      return 'Giảm (${diff.toStringAsFixed(1)})';
    } else {
      return 'Ổn định';
    }
  }
}
