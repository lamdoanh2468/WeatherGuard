import 'package:flutter/foundation.dart';
import 'package:flutter_weather_dashboard/services/weather_service.dart';
import 'package:flutter_weather_dashboard/services/firebase_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>> _weatherList = [];

  List<Map<String, dynamic>> get weatherList => _weatherList;

  // Thêm method init()
  void init() {
    listenToWeatherData();
  }

  void listenToWeatherData() {
    _weatherService.getWeaterData().listen((data) {
      _weatherList = data;
      notifyListeners();
    });
  }
}