import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF74ABE2), // soft blue
              Color(0xFF5583EE), // bright blue
              Color(0xFF4961DC), // rich indigo
            ],
            stops: [0.0, 0.65, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4.1 - Account Info
                _buildSectionTitle(context, 'Account Information'),
                const SizedBox(height: 12),
                _buildProfileCard(context),
                const SizedBox(height: 24),

                // REMOVED: City Settings section (không còn cần vì provider không có city)

                // 4.2 - Station Management
                _buildSectionTitle(context, 'Monitor Station Management'),
                const SizedBox(height: 12),
                _buildStationManagementCard(context),
                const SizedBox(height: 24),

                // 4.3 - Alert Settings
                _buildSectionTitle(context, 'Alerts'),
                const SizedBox(height: 12),
                _buildAlertSettingsCard(context),
                const SizedBox(height: 24),

                // API Keys
                _buildSectionTitle(context, 'System Configuration'),
                const SizedBox(height: 12),
                _buildSystemConfigCard(context),
                const SizedBox(height: 24),

                // Logout
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  // 4.1 - Account Info
  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(''),
                child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
              ),
              const SizedBox(height: 12),
              const Text(
                'User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'user@example.com',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToProfileEdit(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // REMOVED: _buildCityInput widget

  // 4.2 - Station Management
  Widget _buildStationManagementCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.sensors, color: Colors.green),
            title: const Text(
              'My Stations',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('View and manage your monitoring stations'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToMyStations(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
            title: const Text('Add New Station'),
            onTap: () => _navigateToAddStation(context),
          ),
        ],
      ),
    );
  }

  // 4.3 - Alert Settings
  Widget _buildAlertSettingsCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading:
            const Icon(Icons.notifications_active, color: Colors.orange),
            title: const Text(
              'Alert Thresholds',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Customize automatic alert thresholds'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToAlertSettings(context),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAlertThresholdItem(
                  'High Temperature',
                  '> 35°C',
                  Icons.thermostat,
                  Colors.red,
                ),
                const SizedBox(height: 8),
                _buildAlertThresholdItem(
                  'High Humidity',
                  '> 80%',
                  Icons.water_drop,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertThresholdItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemConfigCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.vpn_key, color: Colors.deepPurple),
        title: const Text(
          'API Keys Settings',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: const Text('Configure API keys for the system'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, '/api-keys'),
      ),
    );
  }

  // Navigation handlers
  void _navigateToProfileEdit(BuildContext context) {
    Navigator.pushNamed(context, '/profile-edit');
  }

  void _navigateToMyStations(BuildContext context) {
    Navigator.pushNamed(context, '/my-stations');
  }

  void _navigateToAddStation(BuildContext context) {
    Navigator.pushNamed(context, '/add-station');
  }

  void _navigateToAlertSettings(BuildContext context) {
    Navigator.pushNamed(context, '/alert-settings');
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}