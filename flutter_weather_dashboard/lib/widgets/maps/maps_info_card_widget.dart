import 'package:flutter/material.dart';

class MapsInfoCardWidget extends StatelessWidget {
  final bool hasValidGps;
  final double lat;
  final double lng;
  final double temp;
  final double humidity;
  final String formattedTime;
  final bool hasData;
  final VoidCallback? onCenterMap;

  const MapsInfoCardWidget({
    super.key,
    required this.hasValidGps,
    required this.lat,
    required this.lng,
    required this.temp,
    required this.humidity,
    required this.formattedTime,
    required this.hasData,
    this.onCenterMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasValidGps
              ? [Colors.green.shade600, Colors.green.shade400]
              : [Colors.grey.shade600, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                hasValidGps ? Icons.gps_fixed : Icons.gps_off,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasValidGps ? 'GPS Từ Arduino - Đang Hoạt Động' : 'Chờ Tín Hiệu GPS...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasValidGps
                          ? 'Lat: ${lat.toStringAsFixed(6)} | Lng: ${lng.toStringAsFixed(6)}'
                          : 'Đang chờ dữ liệu từ Firebase...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // Button to center map
              if (hasValidGps && onCenterMap != null)
                IconButton(
                  onPressed: onCenterMap,
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  tooltip: 'Đưa về vị trí sensor',
                ),
            ],
          ),
          if (hasData) ...[
            const Divider(color: Colors.white30, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(Icons.thermostat, '${temp.toStringAsFixed(1)}°C'),
                _buildInfoChip(Icons.water_drop, '${humidity.toStringAsFixed(1)}%'),
                _buildInfoChip(Icons.access_time, formattedTime),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
