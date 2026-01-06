import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/station_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/station/station_card_widget.dart';
import '../widgets/station/gps_info_card_widget.dart';
import '../widgets/station/station_details_dialog.dart';
import '../widgets/station/delete_confirmation_dialog.dart';

class MyStationPage extends StatefulWidget {
  const MyStationPage({super.key});

  @override
  State<MyStationPage> createState() => _MyStationPageState();
}

class _MyStationPageState extends State<MyStationPage> {
  // Helper định dạng vị trí (Helper to format location)
  String _formatLocation(double? lat, double? lng) {
    if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) {
      return 'Chờ tín hiệu GPS...';
    }
    return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Trạm của tôi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF74ABE2),
              Color(0xFF5583EE),
              Color(0xFF4961DC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Consumer<StationProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final double lat = provider.stationLocation?.latitude ?? 0.0;
              final double lng = provider.stationLocation?.longitude ?? 0.0;
              final double temperature = provider.temperature ?? 0.0;
              final double humidity = provider.humidity ?? 0.0;

              final bool hasValidGps = lat != 0.0 && lng != 0.0;

              final station = {
                'id': 'ESP32-001',
                'name': 'Trạm Arduino/ESP32',
                'location': _formatLocation(lat, lng),
                'status': 'active', // Placeholder
                'temperature': temperature,
                'humidity': humidity,
                'lastUpdate':
                    'Vừa xong', // Placeholder vì provider cập nhật thời gian thực
                'lat': lat,
                'lng': lng,
                'hasValidGps': hasValidGps,
              };

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  StationCardWidget(
                    station: station,
                    onTap: () => showStationDetailsDialog(
                      context,
                      station,
                      onDelete: () =>
                          showDeleteConfirmationDialog(context, station),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Thẻ thông tin GPS (GPS Info Card)
                  GpsInfoCardWidget(
                    lat: lat,
                    lng: lng,
                    hasValidGps: hasValidGps,
                    onOpenMap: () {
                      // Đóng trang My Station hiện tại
                      Navigator.pop(context);

                      // Chuyển sang tab Maps (index 2) bằng NavigationProvider
                      context.read<NavigationProvider>().setIndex(2);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
