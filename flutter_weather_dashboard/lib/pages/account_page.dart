import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  double _temperatureThreshold = 35;
  bool _temperatureAlertEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.user != null;

    return Scaffold(
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
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị thông tin user nếu đã đăng nhập
              if (isLoggedIn) ...[
                _buildUserInfo(authProvider),
                const SizedBox(height: 24),
              ],

              // Hiển thị auth cards nếu chưa đăng nhập
              if (!isLoggedIn) ...[
                _accountManagementCards(context),
                const SizedBox(height: 30),
              ],

              // Phần Monitor Stations (hiển thị cho cả logged in và chưa)
              _section("Trạm thời tiết"),
              _quickCard(
                icon: Icons.sensors,
                title: "Trạm của tôi",
                subtitle: "Theo dõi và quản lí trạm thời tiết",
                context: context,
                route: '/my-station',
              ),
              const SizedBox(height: 24),

              // Phần Alerts
              _section("Alerts"),
              _thresholdCard(),
              const SizedBox(height: 32),

              // Logout button (chỉ hiển thị khi đã đăng nhập)
              if (isLoggedIn)
                Center(
                  child: _logoutButton(context, authProvider),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI Components ----------------

  Widget _buildUserInfo(AuthProvider authProvider) {
    final user = authProvider.user!;
    final displayName = user.displayName ?? user.email ?? 'User';
    final email = user.email ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5583EE), Color(0xFF4961DC)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Chỉnh sửa thông tin cá nhân'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountManagementCards(BuildContext context) {
    return Column(
      children: [
        _quickCard(
          icon: Icons.app_registration,
          title: "Đăng ký",
          subtitle: "Tạo tài khoản WeatherGuard",
          context: context,
          route: '/register',
        ),
        _quickCard(
          icon: Icons.login,
          title: "Đăng nhập",
          subtitle: "Truy cập hệ thống",
          context: context,
          route: '/login',
        ),
      ],
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

  Widget _thresholdCard() {
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
              subtitle: const Text("Thông báo khi vượt quá ngưỡng đặt trước"),
              value: _temperatureAlertEnabled,
              onChanged: (value) {
                setState(() => _temperatureAlertEnabled = value);
              },
            ),
            const SizedBox(height: 12),
            Text(
              "Ngưỡng: ${_temperatureThreshold.toInt()}°C",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Slider(
              min: 25,
              max: 50,
              divisions: 25,
              value: _temperatureThreshold,
              label: "${_temperatureThreshold.toInt()}°C",
              onChanged: _temperatureAlertEnabled
                  ? (value) => setState(() => _temperatureThreshold = value)
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: _temperatureAlertEnabled
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Ngưỡng cảnh báo đặt ở ${_temperatureThreshold.toInt()}°C",
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.save),
                label: const Text("Lưu ngưỡng"),
              ),
            ),
          ],
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
                const Icon(Icons.arrow_forward_ios,
                    size: 18, color: Colors.black45),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context, AuthProvider authProvider) {
    return OutlinedButton.icon(
      onPressed: () => _handleLogout(context, authProvider),
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text(
        "Đăng xuất tài khoản",
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

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
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
                  "Đăng xuất khỏi tài khoản",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?",
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
                        child: const Text("Huỷ"),
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
                        onPressed: () async {
                          Navigator.pop(context);

                          // Thực hiện logout
                          await authProvider.signOut();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Đăng xuất tài khoản thành công"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text("Xác nhận"),
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
