class WeatherData {
  final String location;
  final int temperature;
  final int humidity;
  final int windSpeed;
  final int visibility;
  final String condition;
  final String conditionText;
  final int pressure;
  final int feelsLike;
  final int uvIndex;
  final DateTime timestamp;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.condition,
    required this.conditionText,
    required this.pressure,
    required this.feelsLike,
    required this.uvIndex,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        location: json['location'] as String,
        temperature: (json['temperature'] as num).round(),
        humidity: (json['humidity'] as num).round(),
        windSpeed: (json['windSpeed'] as num).round(),
        visibility: (json['visibility'] as num).round(),
        condition: json['condition'] as String,
        conditionText: json['conditionText'] as String,
        pressure: (json['pressure'] as num).round(),
        feelsLike: (json['feelsLike'] as num).round(),
        uvIndex: (json['uvIndex'] as num).round(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'location': location,
        'temperature': temperature,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'visibility': visibility,
        'condition': condition,
        'conditionText': conditionText,
        'pressure': pressure,
        'feelsLike': feelsLike,
        'uvIndex': uvIndex,
        'timestamp': timestamp.toIso8601String(),
      };
}

class AirQualityData {
  final int aqi;
  final num pm25;
  final num pm10;
  final num no2;
  final num so2;
  final num co;
  final num o3;
  final String status;
  final DateTime timestamp;

  const AirQualityData({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.no2,
    required this.so2,
    required this.co,
    required this.o3,
    required this.status,
    required this.timestamp,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) => AirQualityData(
        aqi: (json['aqi'] as num).round(),
        pm25: json['pm25'] as num,
        pm10: json['pm10'] as num,
        no2: json['no2'] as num,
        so2: json['so2'] as num,
        co: json['co'] as num,
        o3: json['o3'] as num,
        status: json['status'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'aqi': aqi,
        'pm25': pm25,
        'pm10': pm10,
        'no2': no2,
        'so2': so2,
        'co': co,
        'o3': o3,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
      };
}

class LocationCoords {
  final double lat;
  final double lon;
  const LocationCoords({required this.lat, required this.lon});
}
