import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../widgets/alerts/status_card_widget.dart';
import '../widgets/alerts/alert_list_widget.dart';
import '../widgets/alerts/current_stats_widget.dart';
import '../widgets/alerts/alerts_header_widget.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> with TickerProviderStateMixin {
  // Bộ điều khiển hiệu ứng động (Animation controllers)
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Thiết lập hiệu ứng động
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Trigger clean load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertsProvider>().loadAlerts();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String? level) {
    switch (level) {
      case 'danger':
        return const Color(0xFFDC2626);
      case 'warning':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<AlertsProvider>(
        builder: (context, provider, child) {
          // If no data yet (e.g. initial load), show loading
          // But provider might have empty alerts and normal status, initialized.
          // We can check if statusLevel is available. provider init with 'normal'.

          final statusLevel = provider.statusLevel;
          final alerts = provider.alerts;
          final currentData = provider.currentData;

          // Pull-to-refresh calls provider load
          return RefreshIndicator(
            color: const Color(0xFFDC2626),
            backgroundColor: Colors.white,
            strokeWidth: 3.0,
            onRefresh: () async => await provider.loadAlerts(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AlertsHeaderWidget(
                        pulseAnimation: _pulseAnimation,
                        statusLevel: statusLevel,
                        getStatusColor: _getStatusColor,
                      ),
                      const SizedBox(height: 20),
                      StatusCardWidget(
                        level: statusLevel,
                        pulseAnimation: _pulseAnimation,
                      ),
                      const SizedBox(height: 20),
                      if (alerts.isNotEmpty) ...[
                        Text(
                          'Chi tiết cảnh báo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AlertListWidget(
                          messages: alerts
                              .map((a) => a['message'] as String)
                              .toList(),
                          statusLevel: statusLevel,
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (currentData != null)
                        CurrentStatsWidget(
                          temperature: currentData['temp'],
                          humidity: currentData['hum'],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
