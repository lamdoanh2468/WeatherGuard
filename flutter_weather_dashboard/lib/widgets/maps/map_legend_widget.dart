import 'package:flutter/material.dart';

class MapLegendWidget extends StatelessWidget {
  const MapLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.memory, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'ESP32 + NEO-7N GPS',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
