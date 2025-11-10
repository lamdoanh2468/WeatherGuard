class WeatherData {
  final DateTime dateTime;
  final double humidity;
  final double temperature;
  final DateTime timestamp;

  const WeatherData({
    required this.dateTime,
    required this.humidity,
    required this.temperature,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        dateTime: DateTime.tryParse(json['datetime'] ?? '') ?? DateTime.now(),
        humidity: (json['humidity'] is num)
            ? (json['humidity'] as num).toDouble()
            : double.tryParse(json['humidity']?.toString() ?? '0') ?? 0,
        temperature: (json['temperature'] is num)
            ? (json['temperature'] as num).toDouble()
            : double.tryParse(json['temperature']?.toString() ?? '0') ?? 0,
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'datetime': dateTime,
        'temperature': temperature,
        'humidity': humidity,
        'timestamp': timestamp.toIso8601String(),
      };

  factory WeatherData.fromFirebase(Map<String, dynamic> json) {
    return WeatherData(
      dateTime: DateTime.tryParse(json['datetime'] ?? '') ?? DateTime.now(),
      temperature: (json['temperature'] is num)
          ? (json['temperature'] as num).toDouble()
          : double.tryParse(json['temperature']?.toString() ?? '0') ?? 0,
      humidity: (json['humidity'] is num)
          ? (json['humidity'] as num).toDouble()
          : double.tryParse(json['humidity']?.toString() ?? '0') ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class LocationCoords {
  final double lat;
  final double lon;

  const LocationCoords({required this.lat, required this.lon});
}
