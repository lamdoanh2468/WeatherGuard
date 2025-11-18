import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> with TickerProviderStateMixin {
  final String apiUrl = "http://10.0.2.2:8000/alerts";

  Map<String, dynamic>? _alertData;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fetchAlerts();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final newData = jsonDecode(response.body);

        // Kiểm tra nếu có nguy hiểm → vibrate
        if (newData['status_level'] == 'danger') {
          HapticFeedback.mediumImpact();
        }

        setState(() {
          _alertData = newData;
          _isLoading = false;
        });

        // Trigger fade in animation
        _fadeController.forward(from: 0.0);
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Lỗi kết nối: $e";
        _isLoading = false;
      });
    }
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

  IconData _getStatusIcon(String? level) {
    switch (level) {
      case 'danger':
        return Icons.warning_amber_rounded;
      case 'warning':
        return Icons.info_outline_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _getStatusText(String? level) {
    switch (level) {
      case 'danger':
        return "NGUY HIỂM";
      case 'warning':
        return "CẢNH BÁO";
      default:
        return "AN TOÀN";
    }
  }

  String _getStatusDescription(String? level) {
    switch (level) {
      case 'danger':
        return "Chỉ số vượt ngưỡng nguy hiểm, xử lý ngay!";
      case 'warning':
        return "Phát hiện bất thường, cần theo dõi";
      default:
        return "Nhiệt độ & độ ẩm trong ngưỡng an toàn";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
        color: const Color(0xFFDC2626),
        backgroundColor: Colors.white,
        strokeWidth: 3.0,
        onRefresh: _fetchAlerts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatusCard(),
                  const SizedBox(height: 20),

                  if (_alertData!['has_alert'] == true) ...[
                    Text(
                      'Chi tiết cảnh báo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAlertList(),
                    const SizedBox(height: 24),
                  ],
                  _buildCurrentStats(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1000),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    color: Color(0xFFDC2626),
                    strokeWidth: 3,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giám Sát Môi Trường',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Theo dõi nhiệt độ & độ ẩm thời gian thực',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final level = _alertData?['status_level'] ?? 'normal';
              final shouldPulse = level == 'danger' || level == 'warning';

              return Transform.scale(
                scale: shouldPulse ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: shouldPulse
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: _getStatusColor(level),
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final level = _alertData!['status_level'] as String? ?? 'normal';
    final color = _getStatusColor(level);
    final icon = _getStatusIcon(level);
    final text = _getStatusText(level);
    final description = _getStatusDescription(level);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.85), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final shouldPulse = level == 'danger';
                    return Transform.scale(
                      scale: shouldPulse ? _pulseAnimation.value : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 48),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertList() {
    final messages = (_alertData!['messages'] as List).cast<String>();
    final level = _alertData!['status_level'] as String?;

    return Column(
      children: List.generate(messages.length, (index) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(
                        color: _getStatusColor(level),
                        width: 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: _getStatusColor(level),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          messages[index],
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
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
      }),
    );
  }

  Widget _buildCurrentStats() {
    final temp = _alertData!['data']['temp'];
    final hum = _alertData!['data']['hum'];

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            "Nhiệt độ",
            "$temp°C",
            Icons.thermostat_outlined,
            const Color(0xFFF59E0B),
            0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            "Độ ẩm",
            "$hum%",
            Icons.water_drop_outlined,
            const Color(0xFF3B82F6),
            1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label,
      String value,
      IconData icon,
      Color color,
      int index,
      ) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, double animValue, child) {
        return Transform.scale(
          scale: animValue,
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
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 24),
                Text(
                  "Mất kết nối",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage ?? "Không thể tải dữ liệu",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _fetchAlerts,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Thử lại"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}