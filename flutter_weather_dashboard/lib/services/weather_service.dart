import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_models.dart';

class WeatherService {
  static const _baseWeatherUrl = 'https://api.openweathermap.org/data/2.5';
  static const _baseAirQualityUrl = 'https://api.waqi.info';

  Future<String> _getOpenWeatherKey() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return dotenv.env['OPENWEATHER_API_KEY'] ??
          prefs.getString('openweather_api_key') ??
          '';
    } catch (e) {
      // Fallback to SharedPreferences if dotenv fails
      return prefs.getString('openweather_api_key') ?? '';
    }
  }

  Future<String> _getAqicnKey() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return dotenv.env['AQICN_API_KEY'] ??
          prefs.getString('aqicn_api_key') ??
          '';
    } catch (e) {
      // Fallback to SharedPreferences if dotenv fails
      return prefs.getString('aqicn_api_key') ?? '';
    }
  }

  Future<bool> _hasValidOpenWeatherKey() async {
    final key = await _getOpenWeatherKey();
    return key.isNotEmpty && key != '2aba6509f642aef657cea68a15d5647e';
  }

  Future<bool> _hasValidAqicnKey() async {
    final key = await _getAqicnKey();
    return key.isNotEmpty && key != '5d3de55f0a4752e96ecd9623386803d6f16ff7b6';
  }

  Future<WeatherData> getCurrentWeather({String city = 'Hanoi'}) async {
    if (!await _hasValidOpenWeatherKey()) {
      return _mockWeatherData();
    }
    try {
      final key = await _getOpenWeatherKey();
      final uri = Uri.parse(
          '$_baseWeatherUrl/weather?q=$city&appid=$key&units=metric&lang=vi');
      final res = await http.get(uri);
      if (res.statusCode != 200) return _mockWeatherData();
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return WeatherData(
        location: '${data['name']}, ${data['sys']['country']}',
        temperature: (data['main']['temp'] as num).round(),
        humidity: (data['main']['humidity'] as num).round(),
        windSpeed: ((data['wind']['speed'] as num) * 3.6).round(),
        visibility: ((data['visibility'] as num) / 1000).round(),
        condition: _mapWeatherCondition(data['weather'][0]['main'] as String),
        conditionText: data['weather'][0]['description'] as String,
        pressure: (data['main']['pressure'] as num).round(),
        feelsLike: (data['main']['feels_like'] as num).round(),
        uvIndex: 0,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      return _mockWeatherData();
    }
  }

  Future<AirQualityData> getAirQuality({String city = 'hanoi'}) async {
    if (!await _hasValidAqicnKey()) {
      return _mockAirQualityData();
    }
    try {
      final key = await _getAqicnKey();
      final uri = Uri.parse('$_baseAirQualityUrl/feed/$city/?token=$key');
      final res = await http.get(uri);
      if (res.statusCode != 200) return _mockAirQualityData();
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['status'] != 'ok') return _mockAirQualityData();
      final aqiData = body['data'] as Map<String, dynamic>;
      final iaqi = (aqiData['iaqi'] as Map<String, dynamic>?) ?? {};
      final aqi = (aqiData['aqi'] as num?) ?? 0;
      return AirQualityData(
        aqi: aqi.round(),
        pm25: (iaqi['pm25']?['v'] as num?) ?? 0,
        pm10: (iaqi['pm10']?['v'] as num?) ?? 0,
        no2: (iaqi['no2']?['v'] as num?) ?? 0,
        so2: (iaqi['so2']?['v'] as num?) ?? 0,
        co: (iaqi['co']?['v'] as num?) ?? 0,
        o3: (iaqi['o3']?['v'] as num?) ?? 0,
        status: _getAQIStatus(aqi.toInt()),
        timestamp:
            DateTime.tryParse(aqiData['time']?['iso'] ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return _mockAirQualityData();
    }
  }

  Future<WeatherData> getWeatherByCoords(LocationCoords coords) async {
    if (!await _hasValidOpenWeatherKey()) {
      return _mockWeatherData();
    }
    try {
      final key = await _getOpenWeatherKey();
      final uri = Uri.parse(
          '$_baseWeatherUrl/weather?lat=${coords.lat}&lon=${coords.lon}&appid=$key&units=metric&lang=vi');
      final res = await http.get(uri);
      if (res.statusCode != 200) return _mockWeatherData();
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return WeatherData(
        location: '${data['name']}, ${data['sys']['country']}',
        temperature: (data['main']['temp'] as num).round(),
        humidity: (data['main']['humidity'] as num).round(),
        windSpeed: ((data['wind']['speed'] as num) * 3.6).round(),
        visibility: ((data['visibility'] as num) / 1000).round(),
        condition: _mapWeatherCondition(data['weather'][0]['main'] as String),
        conditionText: data['weather'][0]['description'] as String,
        pressure: (data['main']['pressure'] as num).round(),
        feelsLike: (data['main']['feels_like'] as num).round(),
        uvIndex: 0,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      return _mockWeatherData();
    }
  }

  Future<List<Map<String, dynamic>>> getForecast(
      {String city = 'Hanoi'}) async {
    if (!await _hasValidOpenWeatherKey()) {
      return _mockForecastData();
    }
    try {
      final key = await _getOpenWeatherKey();
      final uri = Uri.parse(
          '$_baseWeatherUrl/forecast?q=$city&appid=$key&units=metric&lang=vi');
      final res = await http.get(uri);
      if (res.statusCode != 200) return _mockForecastData();
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final List list = (data['list'] as List).take(8).toList();
      return list.map<Map<String, dynamic>>((item) {
        final m = item as Map<String, dynamic>;
        final dt = DateTime.fromMillisecondsSinceEpoch(
            (m['dt'] as num).toInt() * 1000);
        return {
          'time': '${dt.hour}h',
          'temp': (m['main']['temp'] as num).round(),
          'condition': _mapWeatherCondition(m['weather'][0]['main'] as String),
          'humidity': (m['main']['humidity'] as num).round(),
          'description': m['weather'][0]['description'],
        };
      }).toList();
    } catch (_) {
      return _mockForecastData();
    }
  }

  String _mapWeatherCondition(String condition) {
    const map = {
      'Clear': 'sunny',
      'Clouds': 'cloudy',
      'Rain': 'rainy',
      'Drizzle': 'rainy',
      'Thunderstorm': 'stormy',
      'Snow': 'snowy',
      'Mist': 'cloudy',
      'Fog': 'cloudy',
      'Haze': 'cloudy',
    };
    return map[condition] ?? 'partly-cloudy';
  }

  String _getAQIStatus(int aqi) {
    if (aqi <= 50) return 'good';
    if (aqi <= 100) return 'moderate';
    if (aqi <= 150) return 'unhealthy-sensitive';
    if (aqi <= 200) return 'unhealthy';
    if (aqi <= 300) return 'very-unhealthy';
    return 'hazardous';
  }

  WeatherData _mockWeatherData() => WeatherData(
        location: 'Hà Nội, Việt Nam',
        temperature: 28,
        humidity: 75,
        windSpeed: 12,
        visibility: 8,
        condition: 'partly-cloudy',
        conditionText: 'Có mây',
        pressure: 1013,
        feelsLike: 30,
        uvIndex: 5,
        timestamp: DateTime.now(),
      );

  AirQualityData _mockAirQualityData() => AirQualityData(
        aqi: 85,
        pm25: 35,
        pm10: 45,
        no2: 25,
        so2: 15,
        co: 0.8,
        o3: 45,
        status: 'moderate',
        timestamp: DateTime.now(),
      );

  List<Map<String, dynamic>> _mockForecastData() => const [
        {'time': '6h', 'temp': 25, 'condition': 'sunny', 'humidity': 70},
        {
          'time': '9h',
          'temp': 27,
          'condition': 'partly-cloudy',
          'humidity': 65
        },
        {'time': '12h', 'temp': 30, 'condition': 'cloudy', 'humidity': 60},
        {
          'time': '15h',
          'temp': 32,
          'condition': 'partly-cloudy',
          'humidity': 55
        },
        {'time': '18h', 'temp': 29, 'condition': 'cloudy', 'humidity': 65},
        {'time': '21h', 'temp': 26, 'condition': 'rainy', 'humidity': 80},
        {'time': '24h', 'temp': 24, 'condition': 'rainy', 'humidity': 85},
        {'time': '3h', 'temp': 23, 'condition': 'cloudy', 'humidity': 82},
      ];
}

final weatherService = WeatherService();
