import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/firebase_service.dart';

class StationProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _gpsSubscription;

  // Trạng thái (State)
  LatLng? _stationLocation;
  double? _temperature;
  double? _humidity;
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  LatLng? get stationLocation => _stationLocation;
  double? get temperature => _temperature;
  double? get humidity => _humidity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Vị trí mặc định (Việt Nam)
  static const LatLng defaultLocation = LatLng(10.8231, 106.6297);

  /// Tải tọa độ GPS từ Firebase Realtime Database
  void loadGPSFromFirebase() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _gpsSubscription?.cancel();
      _gpsSubscription = _firebaseService.getWeatherStream().listen((dataList) {
        if (dataList.isNotEmpty) {
          // Lấy dữ liệu mới nhất (first vì đã sort newest first)
          final latestData = dataList.first;
          final lat = latestData['lat'];
          final lng = latestData['lng'];
          final temp = latestData['temperature'];
          final hum = latestData['humidity'];

          double latitude =
              (lat is int) ? lat.toDouble() : (lat ?? 0.0).toDouble();
          double longitude =
              (lng is int) ? lng.toDouble() : (lng ?? 0.0).toDouble();
          _temperature =
              (temp is int) ? temp.toDouble() : (temp ?? 0.0).toDouble();
          _humidity = (hum is int) ? hum.toDouble() : (hum ?? 0.0).toDouble();

          // Kiểm tra GPS có hợp lệ không
          if (latitude != 0.0 && longitude != 0.0) {
            _stationLocation = LatLng(latitude, longitude);
            _errorMessage = null;
          } else {
            _errorMessage = 'Đang chờ tín hiệu GPS từ Arduino...';
          }
        } else {
          _errorMessage = 'Chưa có dữ liệu từ trạm thời tiết';
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _isLoading = false;
        _errorMessage = 'Lỗi kết nối Firebase: $error';
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    super.dispose();
  }
}
