import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

// Quyết định hiện trang nào khi mở web:
// - Chưa đăng nhập: vẫn hiện trang chủ (chế độ khách)
// - Đã đăng nhập: hiện trang chủ kèm thông tin người dùng
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }
        final firebaseUser = authSnap.data;

        // Chưa đăng nhập -> trang chủ cho khách
        if (firebaseUser == null) return const HomeScreen();

        // Đã đăng nhập -> lấy hồ sơ trong Firestore
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .snapshots(),
          builder: (context, docSnap) {
            if (docSnap.hasError) {
              return Scaffold(
                body: Center(child: Text('Lỗi: ${docSnap.error}')),
              );
            }
            if (!docSnap.hasData || !docSnap.data!.exists) {
              return const _Loading(); // đang chờ tạo hồ sơ
            }
            final user = UserModel.fromMap(docSnap.data!.data()!);

            // Tài khoản bị khoá -> đăng xuất, quay về chế độ khách
            if (!user.isActive) {
              AuthService().logout();
              return const HomeScreen();
            }
            return HomeScreen(user: user);
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
