import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final User user;
  final bool isEditing;
  final VoidCallback? onEditPhoto;

  const ProfileAvatarWidget({
    super.key,
    required this.user,
    required this.isEditing,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: user.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      user.photoURL!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF5583EE),
                  ),
          ),
        ),
        if (isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditPhoto,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5583EE),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
