import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Đăng ký: tạo tài khoản Auth rồi tạo document users/{uid}
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = UserModel(
      uid: cred.user!.uid,
      email: email,
      displayName: displayName,
      role: 'user', // rules chỉ cho phép tạo với role 'user'
    );
    await _db.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  // Đăng nhập: kiểm tra tài khoản có bị khoá không
  Future<UserModel> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final doc = await _db.collection('users').doc(cred.user!.uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      throw Exception('Không tìm thấy hồ sơ người dùng');
    }
    final user = UserModel.fromMap(doc.data()!);
    if (!user.isActive) {
      await _auth.signOut();
      throw Exception('Tài khoản đã bị khoá');
    }
    return user;
  }

  Future<void> logout() => _auth.signOut();

  // Lấy thông tin user hiện tại (dùng khi mở lại app)
  Future<UserModel?> getCurrentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final doc = await _db.collection('users').doc(u.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }
}
