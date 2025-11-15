import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherProvider extends ChangeNotifier {
  Map<String, dynamic>? latest;
  List<Map<String, dynamic>> weatherList = [];
  Map<String, dynamic>? stats;
  Timer? _timer;

  final String apiBase = 'http://10.0.2.2:8000';

  WeatherProvider() {
    _startPolling();
  }

  void _startPolling() {
    // Polling 5 giây
    _fetchLatest();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchLatest());
  }

  Future<void> _fetchLatest() async {
    try {
      final response = await http.get(Uri.parse('$apiBase/latest'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        latest = data;

        // Lưu lại history tối đa 10 bản ghi
        if (data.isNotEmpty) {
          // Lấy timestamp của bản ghi mới nhất trong weatherList
          final lastTimestamp =
              weatherList.isNotEmpty ? weatherList.first['timestamp'] : null;

          // Chỉ thêm nếu timestamp khác
          if (lastTimestamp != data['timestamp']) {
            weatherList.insert(0, data);
            if (weatherList.length > 10) {
              weatherList = weatherList.take(10).toList();
            }
          }
        }
        notifyListeners();
      } else {
        debugPrint('Failed to fetch latest weather: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching latest weather: $e');
    }
  }

  Future<void> loadLatest() async => _fetchLatest();

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(Uri.parse('$apiBase/stats'));
      if (response.statusCode == 200) {
        stats = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  Future<void> _fetchRealtime() async {
    try {
      final response = await http.get(Uri.parse('$apiBase/realtime'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // data phải trả về list 60 bản ghi forecast + cluster
        // lưu vào weatherList hoặc chartData
        // mình dùng weatherList cho chart
        if (data is Map && data.containsKey('forecast')) {
          weatherList = List<Map<String, dynamic>>.from(data['forecast']);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching realtime: $e');
    }
  }
  Future<void> loadStats() async => _fetchStats();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
