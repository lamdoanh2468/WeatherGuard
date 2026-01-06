import 'package:flutter/material.dart';

class GpsWarningBannerWidget extends StatelessWidget {
  const GpsWarningBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Arduino chưa có tín hiệu GPS. Đảm bảo module GPS ở ngoài trời.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
