import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'gps_row_widget.dart';

class GpsInfoCardWidget extends StatelessWidget {
  final double lat;
  final double lng;
  final bool hasValidGps;
  final VoidCallback? onOpenMap;

  const GpsInfoCardWidget({
    super.key,
    required this.lat,
    required this.lng,
    required this.hasValidGps,
    this.onOpenMap,
  });

  /// Mở Google Maps với chỉ đường đến vị trí GPS
  Future<void> _openGoogleMapsNavigation() async {
    if (!hasValidGps) return;

    // URL để mở Google Maps với chỉ đường
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Mở vị trí trong Google Maps
  Future<void> _openLocationInMaps() async {
    if (!hasValidGps) return;

    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasValidGps
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasValidGps ? Icons.gps_fixed : Icons.gps_off,
                  color: hasValidGps ? Colors.green : Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin GPS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasValidGps ? 'Đang hoạt động' : 'Chờ tín hiệu...',
                      style: TextStyle(
                        fontSize: 14,
                        color: hasValidGps ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasValidGps) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  GpsRowWidget(label: 'Vĩ độ', value: lat.toStringAsFixed(6)),
                  const SizedBox(height: 8),
                  GpsRowWidget(label: 'Kinh độ', value: lng.toStringAsFixed(6)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Các nút thao tác
            Row(
              children: [
                // Nút xem trong app
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.map,
                    label: 'Xem bản đồ',
                    color: Colors.blue,
                    onTap: onOpenMap,
                  ),
                ),
                const SizedBox(width: 12),
                // Nút mở Google Maps
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.open_in_new,
                    label: 'Google Maps',
                    color: Colors.green,
                    onTap: _openLocationInMaps,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nút chỉ đường
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                icon: Icons.directions,
                label: 'Chỉ đường đến trạm',
                color: Colors.indigo,
                onTap: _openGoogleMapsNavigation,
                isFullWidth: true,
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đảm bảo module GPS NEO-6M ở ngoài trời để nhận tín hiệu.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool isFullWidth = false,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isFullWidth ? 14 : 12,
            horizontal: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: isFullWidth ? 15 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
