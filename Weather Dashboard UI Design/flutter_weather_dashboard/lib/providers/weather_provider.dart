import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_models.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? weather;
  AirQualityData? airQuality;
  List<Map<String, dynamic>> forecast = const [];
  String city = 'Hanoi';
  bool loading = false;
  String? error;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    city = prefs.getString('city') ?? 'Hanoi';
    await refreshAll();
  }

  Future<void> refreshAll() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        weatherService.getCurrentWeather(city: city),
        weatherService.getAirQuality(city: city.toLowerCase()),
        weatherService.getForecast(city: city),
      ]);
      weather = results[0] as WeatherData;
      airQuality = results[1] as AirQualityData;
      forecast = results[2] as List<Map<String, dynamic>>;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setCity(String newCity) async {
    city = newCity;
    (await SharedPreferences.getInstance()).setString('city', city);
    await refreshAll();
  }

  Future<void> saveApiKeys({String? openWeather, String? aqicn}) async {
    final prefs = await SharedPreferences.getInstance();
    if (openWeather != null) {
      await prefs.setString('openweather_api_key', openWeather);
    }
    if (aqicn != null) {
      await prefs.setString('aqicn_api_key', aqicn);
    }
    await refreshAll();
  }
}
