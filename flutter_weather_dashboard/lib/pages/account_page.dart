import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/account/user_info_widget.dart';
import '../widgets/account/section_header_widget.dart';
import '../widgets/account/quick_card_widget.dart';
import '../widgets/account/threshold_card_widget.dart';
import '../widgets/account/logout_button_widget.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

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
                UserInfoWidget(authProvider: authProvider),
                const SizedBox(height: 24),
              ],

              // Hiển thị auth cards nếu chưa đăng nhập
              if (!isLoggedIn) ...[
                const QuickCardWidget(
                  icon: Icons.app_registration,
                  title: "Đăng ký",
                  subtitle: "Tạo tài khoản WeatherGuard",
                  route: '/register',
                ),
                const QuickCardWidget(
                  icon: Icons.login,
                  title: "Đăng nhập",
                  subtitle: "Truy cập hệ thống",
                  route: '/login',
                ),
                const SizedBox(height: 30),
              ],

              // Phần trạm quan trắc (Monitor Stations)
              const SectionHeaderWidget(title: "Trạm thời tiết"),
              const QuickCardWidget(
                icon: Icons.sensors,
                title: "Trạm của tôi",
                subtitle: "Theo dõi và quản lí trạm thời tiết",
                route: '/my-station',
              ),
              const SizedBox(height: 24),

              // Phần Cảnh báo (Alerts)
              const SectionHeaderWidget(title: "Cảnh báo ngưỡng"),
              const ThresholdCardWidget(),
              const SizedBox(height: 32),

              // Logout button (chỉ hiển thị khi đã đăng nhập)
              if (isLoggedIn)
                Center(
                  child: LogoutButtonWidget(authProvider: authProvider),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
