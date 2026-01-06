import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AlertsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> alerts = [];
  String statusLevel = 'normal';
  Map<String, dynamic>? currentData;
  Timer? _timer;

  final String apiBase = 'http://10.0.2.2:8000';

  AlertsProvider() {
    _loadSettings();
    _startPolling();
  }

  double _tempThreshold = 35.0;
  bool _isThresholdEnabled = true;

  double get tempThreshold => _tempThreshold;
  bool get isThresholdEnabled => _isThresholdEnabled;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _tempThreshold = prefs.getDouble('tempThreshold') ?? 35.0;
    _isThresholdEnabled = prefs.getBool('isThresholdEnabled') ?? true;
    notifyListeners();
  }

  Future<void> saveSettings(double threshold, bool enabled) async {
    _tempThreshold = threshold;
    _isThresholdEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tempThreshold', threshold);
    await prefs.setBool('isThresholdEnabled', enabled);

    // Refresh alerts immediately with new settings
    _fetchAlerts();
  }

  void _startPolling() {
    // Polling mỗi 5 giây để lấy alerts mới
    _fetchAlerts();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchAlerts());
  }

  Future<void> _fetchAlerts() async {
    try {
      // Build URL with optional threshold parameter
      String url = '$apiBase/alerts';
      if (_isThresholdEnabled) {
        url += '?temp_high=$_tempThreshold';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // API trả về object: {status_level, has_alert, messages: [], data: {temp, hum}}
        if (data is Map) {
          if (data.containsKey('status_level')) {
            statusLevel = data['status_level'];
          }
          if (data.containsKey('data')) {
            currentData = data['data'];
          }

          if (data.containsKey('messages')) {
            final messages = List<String>.from(data['messages']);

            final newAlerts = messages
                .map((msg) => {
                      'id': DateTime.now().millisecondsSinceEpoch.toString() +
                          msg.hashCode.toString(),
                      'title': 'Cảnh báo thời tiết',
                      'message': msg,
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                      'isRead': false,
                      'type':
                          msg.contains('NGUY HIỂM') || msg.contains('BÁO ĐỘNG')
                              ? 'danger'
                              : 'warning'
                    })
                .toList();

            // Simple comparison to avoid infinite rebuilds (can be improved)
            if (alerts.length != newAlerts.length ||
                (alerts.isNotEmpty &&
                    newAlerts.isNotEmpty &&
                    alerts.first['message'] != newAlerts.first['message']) ||
                // Also notify if status level changed
                (alerts.isEmpty &&
                    newAlerts.isEmpty &&
                    statusLevel != data['status_level'])) {
              alerts = newAlerts;
              notifyListeners();
            } else {
              // Notify anyway to update temp/hum display if needed
              notifyListeners();
            }
          } else {
            // If 'messages' key is not present, but statusLevel or currentData might have changed
            notifyListeners();
          }
        }
      } else {
        debugPrint('Failed to fetch alerts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
    }
  }

  Future<void> loadAlerts() async => _fetchAlerts();

  // Đánh dấu alert đã đọc
  Future<void> markAsRead(String alertId) async {
    // Local update only for now as backend doesn't support individual message read status yet
    final index = alerts.indexWhere((a) => a['id'] == alertId);
    if (index != -1) {
      alerts[index]['isRead'] = true;
      notifyListeners();
    }
  }

  // Xóa alert
  Future<void> deleteAlert(String alertId) async {
    alerts.removeWhere((a) => a['id'] == alertId);
    notifyListeners();
  }

  // Xóa tất cả alerts
  Future<void> clearAllAlerts() async {
    alerts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
