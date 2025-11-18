import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Account",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF74ABE2),
              Color(0xFF5583EE),
              Color(0xFF4961DC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 110, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(),
              const SizedBox(height: 30),

              _section("Monitor Stations"),
              _quickCard(
                icon: Icons.sensors,
                title: "My Stations",
                subtitle: "View and manage your monitoring stations",
                context: context,
                route: '/my-stations',
              ),
              _quickCard(
                icon: Icons.add_circle_outline,
                title: "Add New Station",
                subtitle: "Register a new monitoring device",
                context: context,
                route: '/add-station',
              ),

              const SizedBox(height: 24),

              _section("Alerts"),
              _quickCard(
                icon: Icons.notifications_active,
                title: "Alert Thresholds",
                subtitle: "Customize your alert conditions",
                context: context,
                route: '/alert-settings',
              ),
              const SizedBox(height: 32),
              Center(
                child: _logoutButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI Components ----------------

  Widget _profileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 48, color: Colors.blueAccent),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "User",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "user@example.com",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: () {},
            child: const Text("Edit Profile"),
          )
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _quickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required BuildContext context,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 32, color: Colors.blueAccent),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black45),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _handleLogout(context),
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text(
        "Logout",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
      ),
    );
  }

  // ---------------- Logic ----------------

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon cảnh báo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                const Text(
                  "Log Out?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "Are you sure you want to log out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Logged out successfully"),
                            ),
                          );
                        },
                        child: const Text("Logout"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

}
