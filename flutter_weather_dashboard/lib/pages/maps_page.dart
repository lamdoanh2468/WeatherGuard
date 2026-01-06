import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/station_provider.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Chỉ tải dữ liệu một lần khi trang được khởi tạo
    Future.microtask(
        () => context.read<StationProvider>().loadGPSFromFirebase());
  }

  void _updateMarkers(StationProvider provider) {
    if (provider.stationLocation != null) {
      _markers = {
        Marker(
          markerId: const MarkerId('weather_station'),
          position: provider.stationLocation!,
          infoWindow: InfoWindow(
            title: 'Trạm Thời Tiết',
            snippet:
                '${provider.temperature?.toStringAsFixed(1)}°C | ${provider.humidity?.toStringAsFixed(0)}%',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      };
    }
  }

  Future<void> _animateToLocation(LatLng? location) async {
    if (location != null && _controller.isCompleted) {
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StationProvider>(
      builder: (context, provider, child) {
        // Update markers whenever provider notifies changes
        _updateMarkers(provider);

        // Auto animate if location becomes available and map is ready
        if (provider.stationLocation != null) {
          _animateToLocation(provider.stationLocation);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children: [
              // GPS Info Card
              _buildGPSInfoCard(provider),

              // Weather Info (if available)
              if (provider.temperature != null && provider.humidity != null)
                _buildWeatherInfoCard(provider),

              // Map
              Expanded(
                child: _buildMap(provider),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _animateToLocation(provider.stationLocation),
            backgroundColor: Colors.blue.shade600,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildGPSInfoCard(StationProvider provider) {
    final hasValidGps = provider.stationLocation != null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasValidGps ? Icons.gps_fixed : Icons.gps_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Vị Trí Trạm Thời Tiết',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (provider.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.errorMessage!,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildCoordinateItem(
                    'Vĩ độ',
                    provider.stationLocation?.latitude.toStringAsFixed(6) ??
                        '---',
                    Icons.north,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCoordinateItem(
                    'Kinh độ',
                    provider.stationLocation?.longitude.toStringAsFixed(6) ??
                        '---',
                    Icons.east,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfoCard(StationProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildWeatherItem(
              Icons.thermostat,
              '${provider.temperature?.toStringAsFixed(1)}°C',
              'Nhiệt độ',
              Colors.orange),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildWeatherItem(
              Icons.water_drop,
              '${provider.humidity?.toStringAsFixed(0)}%',
              'Độ ẩm',
              Colors.blue),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(
      IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoordinateItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap(StationProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: StationProvider.defaultLocation,
            zoom: 12,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }
            if (provider.stationLocation != null) {
              _animateToLocation(provider.stationLocation);
            }
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}
