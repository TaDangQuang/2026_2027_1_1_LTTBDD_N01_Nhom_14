import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AdminHomeScreen extends StatelessWidget {
  final UserModel user;
  const AdminHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang quản trị'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: Center(child: Text('Xin chào admin ${user.displayName}')),
    );
  }
}
