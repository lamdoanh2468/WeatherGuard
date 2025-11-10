import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("sensor_data");

  Stream<List<Map<String, dynamic>>> getWeatherStream() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
      return map.entries.map((e) {
        final value = Map<String, dynamic>.from(e.value);
        return {
          "id": e.key,
          "datetime": value["datetime"] ?? "",
          "temperature": value["temperature"] ?? 0,
          "humidity": value["humidity"] ?? 0,
          "timestamp": value["timestamp"] ?? 0,
        };
      }).toList()
        ..sort((a, b) => (b["timestamp"]).compareTo(a["timestamp"])); // Mới nhất lên đầu
    });
  }
}
