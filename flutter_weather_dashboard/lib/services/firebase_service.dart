import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Lấy luồng dữ liệu thời tiết từ Firebase Realtime Database
  Stream<List<Map<String, dynamic>>> getWeatherStream() {
    return _database
        .ref('sensor_data') // Đổi từ weather_data thành sensor_data
        .orderByChild('timestamp')
        .limitToLast(10)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return <Map<String, dynamic>>[];

      List<Map<String, dynamic>> weatherList = [];

      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            weatherList.add({
              'id': key,
              'temperature': value['temperature'] ?? 0.0,
              'humidity': value['humidity'] ?? 0.0,
              'lat': value['lat'] ?? value['latitude'] ?? 0.0,
              'lng': value['lng'] ?? value['longitude'] ?? 0.0,
              'timestamp': value['timestamp'] ?? 0,
            });
          }
        });
      }

      // Sắp xếp theo thời gian giảm dần (mới nhất trước)
      weatherList.sort((a, b) {
        final timestampA = a['timestamp'] ?? 0;
        final timestampB = b['timestamp'] ?? 0;
        return timestampB.compareTo(timestampA);
      });

      return weatherList;
    });
  }

  /// Lấy vị trí trạm từ Firestore
  Stream<Map<String, dynamic>?> getStationLocation() {
    return _firestore
        .collection('stations')
        .doc('weather_station')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  /// Lưu dữ liệu thời tiết lên Firebase
  Future<void> saveWeatherData({
    required double temperature,
    required double humidity,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final ref = _database.ref('sensor_data').push();
      await ref.set({
        'temperature': temperature,
        'humidity': humidity,
        'lat': latitude ?? 0.0,
        'lng': longitude ?? 0.0,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      throw 'Không thể lưu dữ liệu thời tiết: $e';
    }
  }

  /// Cập nhật vị trí trạm trong Firestore
  Future<void> updateStationLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('stations').doc('weather_station').set({
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Không thể cập nhật vị trí trạm: $e';
    }
  }

  /// Lấy dữ liệu thời tiết mới nhất
  Future<Map<String, dynamic>?> getLatestWeatherData() async {
    try {
      final snapshot = await _database
          .ref('sensor_data')
          .orderByChild('timestamp')
          .limitToLast(1)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map;
        final entry = data.entries.first;
        final value = entry.value as Map;
        return {
          'id': entry.key,
          'temperature': value['temperature'] ?? 0.0,
          'humidity': value['humidity'] ?? 0.0,
          'lat': value['lat'] ?? value['latitude'] ?? 0.0,
          'lng': value['lng'] ?? value['longitude'] ?? 0.0,
          'timestamp': value['timestamp'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      throw 'Không thể lấy dữ liệu thời tiết: $e';
    }
  }
}
