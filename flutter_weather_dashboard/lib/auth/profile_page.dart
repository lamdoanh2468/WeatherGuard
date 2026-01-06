import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile/profile_avatar_widget.dart';
import '../widgets/profile/profile_form_widget.dart';
import '../widgets/profile/profile_options_widget.dart';
import '../widgets/profile/change_password_dialog.dart';
import '../widgets/profile/email_verification_badge.dart';
import '../widgets/profile/not_logged_in_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final userData = authProvider.userData;

    if (user != null) {
      _nameController.text = userData?['name'] ?? user.displayName ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = userData?['phone'] ?? '';
      _addressController.text = userData?['address'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (mounted) {
      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Cập nhật thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleCancel() {
    setState(() {
      _isEditing = false;
      _loadUserData();
    });
  }

  Future<void> _handleVerifyEmail(AuthProvider authProvider) async {
    final success = await authProvider.sendEmailVerification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Email xác thực đã được gửi!' : 'Gửi email thất bại',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
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
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;

              if (user == null) {
                return const NotLoggedInWidget();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Avatar
                    ProfileAvatarWidget(
                      user: user,
                      isEditing: _isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Email verification badge
                    if (!user.emailVerified) const EmailVerificationBadge(),
                    const SizedBox(height: 32),

                    // Profile Form
                    ProfileFormWidget(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      addressController: _addressController,
                      isEditing: _isEditing,
                      isLoading: authProvider.isLoading,
                      onSave: _handleSave,
                      onCancel: _handleCancel,
                    ),
                    const SizedBox(height: 24),

                    // Additional Options
                    ProfileOptionsWidget(
                      showEmailVerification: !user.emailVerified,
                      onChangePassword: () => showChangePasswordDialog(context),
                      onVerifyEmail: () => _handleVerifyEmail(authProvider),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
