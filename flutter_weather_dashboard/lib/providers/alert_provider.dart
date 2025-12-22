import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlertsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> alerts = [];
  Timer? _timer;

  final String apiBase = 'http://10.0.2.2:8000';

  AlertsProvider() {
    _startPolling();
  }

  void _startPolling() {
    // Polling mỗi 5 giây để lấy alerts mới
    _fetchAlerts();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchAlerts());
  }

  Future<void> _fetchAlerts() async {
    try {
      final response = await http.get(Uri.parse('$apiBase/alerts'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Giả sử API trả về list alerts
        if (data is List) {
          // Chỉ cập nhật nếu có alerts mới
          final newAlerts = List<Map<String, dynamic>>.from(data);

          // Kiểm tra xem có alert mới không (so sánh với alert đầu tiên)
          if (alerts.isEmpty ||
              (newAlerts.isNotEmpty &&
                  newAlerts.first['timestamp'] != alerts.first['timestamp'])) {
            alerts = newAlerts;
            notifyListeners();
          }
        } else if (data is Map && data.containsKey('alerts')) {
          // Trường hợp API trả về object với key 'alerts'
          final newAlerts = List<Map<String, dynamic>>.from(data['alerts']);

          if (alerts.isEmpty ||
              (newAlerts.isNotEmpty &&
                  newAlerts.first['timestamp'] != alerts.first['timestamp'])) {
            alerts = newAlerts;
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
    try {
      final response = await http.post(
        Uri.parse('$apiBase/alerts/$alertId/read'),
      );
      if (response.statusCode == 200) {
        // Cập nhật local state
        final index = alerts.indexWhere((a) => a['id'] == alertId);
        if (index != -1) {
          alerts[index]['isRead'] = true;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error marking alert as read: $e');
    }
  }

  // Xóa alert
  Future<void> deleteAlert(String alertId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBase/alerts/$alertId'),
      );
      if (response.statusCode == 200) {
        alerts.removeWhere((a) => a['id'] == alertId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting alert: $e');
    }
  }

  // Xóa tất cả alerts
  Future<void> clearAllAlerts() async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBase/alerts/clear'),
      );
      if (response.statusCode == 200) {
        alerts.clear();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error clearing alerts: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}