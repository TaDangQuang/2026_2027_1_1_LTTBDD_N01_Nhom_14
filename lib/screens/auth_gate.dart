import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

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
        if (firebaseUser == null) return const LoginScreen();

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

            if (!user.isActive) {
              AuthService().logout();
              return const LoginScreen();
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
