import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: Center(child: Text('Xin chào ${user.displayName} (user)')),
    );
  }
}
