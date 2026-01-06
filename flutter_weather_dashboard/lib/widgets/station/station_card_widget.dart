import 'package:flutter/material.dart';
import 'data_item_widget.dart';

class StationCardWidget extends StatelessWidget {
  final Map<String, dynamic> station;
  final VoidCallback? onTap;

  const StationCardWidget({
    super.key,
    required this.station,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = station['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(isActive),
                const SizedBox(height: 20),

                // Hiển thị dữ liệu (Data Display)
                if (isActive) ...[
                  _buildDataRow(),
                  const SizedBox(height: 16),
                ],

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isActive) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.sensors,
            color: isActive ? Colors.green : Colors.grey,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station['name'] ?? 'Không tên',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      station['location'] ?? 'Không xác định',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Nhãn trạng thái (Status Badge)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isActive ? 'Hoạt động' : 'Ngưng',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow() {
    return Row(
      children: [
        Expanded(
          child: DataItemWidget(
            icon: Icons.thermostat,
            label: 'Nhiệt độ',
            value: '${station['temperature']}°C',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DataItemWidget(
            icon: Icons.water_drop,
            label: 'Độ ẩm',
            value: '${station['humidity']}%',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 6),
        Text(
          'Cập nhật: ${station['lastUpdate'] ?? 'N/A'}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          'ID: ${station['id'] ?? 'N/A'}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
