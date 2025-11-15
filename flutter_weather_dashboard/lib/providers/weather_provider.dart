import 'package:flutter/foundation.dart';
import 'package:flutter_weather_dashboard/services/firebase_service.dart';

class WeatherProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _weatherList = [];

  List<Map<String, dynamic>> get weatherList => _weatherList;

  // Thêm method init()
  void init() {
    listenToWeatherData();
  }

  void listenToWeatherData() {
    _firebaseService.getWeatherStream().listen((data) {
      _weatherList = data.map((e) {
        return {
          'datetime': _normalizeTime(e['datetime']),
          'timestamp': _normalizeTime(e['timestamp']),
          'temperature': _parseDouble(e['temperature']),
          'humidity': _parseDouble(e['humidity']),
        };
      }).toList();

      // Mới nhất lên đầu
      _weatherList.sort((a, b) => b['datetime'].compareTo(a['datetime']));
      notifyListeners();
    });
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  /// Chấp nhận cả String và int cho datetime/timestamp
  String _normalizeTime(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) {
      try {
        final dt = DateTime.fromMillisecondsSinceEpoch(value * 1000);
        return dt.toIso8601String();
      } catch (_) {
        return value.toString();
      }
    }
    return value.toString();
  }
}
