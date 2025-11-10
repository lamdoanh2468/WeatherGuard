import 'firebase_service.dart';

class WeatherService {
  final FirebaseService _firebaseService = FirebaseService();

  Stream<List<Map<String, dynamic>>> getWeaterData() {
    return _firebaseService.getWeatherStream();
  }
}
