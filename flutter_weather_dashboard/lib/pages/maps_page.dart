import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Position? _position;
  String? _error;

  Future<void> _getLocation() async {
    setState(() => _error = null);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _error = 'Dịch vụ vị trí đang tắt');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _error = 'Quyền vị trí bị từ chối');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _error = 'Quyền vị trí bị từ chối vĩnh viễn');
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      setState(() => _position = pos);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bản đồ (placeholder)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _getLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Lấy vị trí hiện tại'),
          ),
          const SizedBox(height: 12),
          if (_error != null) Text('Lỗi: $_error'),
          if (_position != null)
            Text('Vĩ độ: ${_position!.latitude}, Kinh độ: ${_position!.longitude}')
          else
            const Text('Chưa có vị trí'),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('Khu vực hiển thị bản đồ sau này'),
            ),
          )
        ],
      ),
    );
  }
}
