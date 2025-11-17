import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_weather_dashboard/providers/alert_provider.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  void initState() {
    super.initState();
    // Load alerts khi page được khởi tạo
    Future.microtask(
          () => context.read<AlertsProvider>().loadAlerts(),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  String _getAlertTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'warning':
        return '⚠️';
      case 'danger':
        return '🚨';
      case 'info':
        return 'ℹ️';
      case 'success':
        return '✅';
      default:
        return '🔔';
    }
  }

  Color _getAlertColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'danger':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'success':
        return Colors.green;
      default:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          Consumer<AlertsProvider>(
            builder: (context, provider, _) {
              if (provider.alerts.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All Alerts'),
                      content: const Text(
                        'Are you sure you want to clear all alerts?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await provider.clearAllAlerts();
                  }
                },
                tooltip: 'Clear all alerts',
              );
            },
          ),
        ],
      ),
      body: Consumer<AlertsProvider>(
        builder: (context, provider, _) {
          if (provider.alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No new alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Waiting for real-time data from server...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadAlerts,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.alerts.length,
              itemBuilder: (context, index) {
                final alert = provider.alerts[index];
                final isRead = alert['isRead'] == true;
                final alertType = alert['type'] ?? 'warning';
                final alertColor = _getAlertColor(alertType);

                return Dismissible(
                  key: Key(alert['id']?.toString() ?? index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    provider.deleteAlert(alert['id']?.toString() ?? '');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alert deleted'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Card(
                    elevation: isRead ? 1 : 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isRead
                          ? BorderSide.none
                          : BorderSide(
                        color: alertColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: alertColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: alertColor,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        alert['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                          fontSize: 16,
                          color: isRead ? Colors.grey[600] : null,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          alert['body'] ?? alert['message'] ?? 'No Message',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(alert['timestamp']),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: alertColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        if (!isRead) {
                          provider.markAsRead(alert['id']?.toString() ?? '');
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}