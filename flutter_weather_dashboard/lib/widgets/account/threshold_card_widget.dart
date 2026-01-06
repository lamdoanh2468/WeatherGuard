import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alert_provider.dart';

class ThresholdCardWidget extends StatelessWidget {
  const ThresholdCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, child) {
        final double threshold = provider.tempThreshold;
        final bool isEnabled = provider.isThresholdEnabled;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Cảnh báo nhiệt độ cao",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle:
                      const Text("Thông báo khi vượt quá ngưỡng đặt trước"),
                  value: isEnabled,
                  onChanged: (value) {
                    provider.saveSettings(threshold, value);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  "Ngưỡng: ${threshold.toInt()}°C",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Slider(
                  min: 25,
                  max: 50,
                  divisions: 25,
                  value: threshold,
                  label: "${threshold.toInt()}°C",
                  onChanged: isEnabled
                      ? (value) => provider.saveSettings(value, isEnabled)
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: isEnabled
                        ? () {
                            // Logic lưu đã được xử lý real-time ở onChanged, nút này chỉ để feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Đã cập nhật ngưỡng cảnh báo: ${threshold.toInt()}°C",
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.check),
                    label: const Text("Đã lưu"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
