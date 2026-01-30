import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alert_provider.dart';

class ThresholdCardWidget extends StatefulWidget {
  const ThresholdCardWidget({super.key});

  @override
  State<ThresholdCardWidget> createState() => _ThresholdCardWidgetState();
}

class _ThresholdCardWidgetState extends State<ThresholdCardWidget> {
  bool _isSaved = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleSave() {
    setState(() {
      _isSaved = true;
    });

    // Reset after 5 seconds
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isSaved = false;
        });
      }
    });

    // Optional: Keep the snackbar feedback or remove it?
    // User only asked for button text change, but keeping snackbar is nice.
    // However, the button itself now acts as feedback. I'll keep it concise.
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear previous overlaps
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã lưu cấu hình cảnh báo"),
        duration: Duration(seconds: 1),
      ),
    );
  }

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
                    onPressed: isEnabled ? _handleSave : null,
                    icon: Icon(_isSaved ? Icons.check : Icons.save),
                    label: Text(_isSaved ? "Đã lưu" : "Lưu"),
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
