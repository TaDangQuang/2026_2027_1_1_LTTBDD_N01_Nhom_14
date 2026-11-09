import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ten = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final xacNhan = TextEditingController();
  bool an1 = true;
  bool an2 = true;
  bool dangTai = false;
  String loi = '';

  // Bấm nút Đăng ký
  Future<void> dangKy() async {
    // Kiểm tra dữ liệu nhập
    if (ten.text.trim().isEmpty || email.text.trim().isEmpty) {
      setState(() => loi = 'Vui lòng nhập đầy đủ thông tin');
      return;
    }
    if (password.text.length < 8) {
      setState(() => loi = 'Mật khẩu phải có ít nhất 8 ký tự');
      return;
    }
    if (password.text != xacNhan.text) {
      setState(() => loi = 'Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() {
      dangTai = true;
      loi = '';
    });
    try {
      await AuthService().register(
        email: email.text.trim(),
        password: password.text,
        displayName: ten.text.trim(),
      );
      if (mounted)
        Navigator.pop(context); // đóng trang, AuthGate tự vào trang chủ
      return;
    } catch (e) {
      loi = 'Đăng ký thất bại, email có thể đã được dùng';
    }
    if (mounted) setState(() => dangTai = false);
  }

  // Ô nhập dùng chung cho cả 4 ô
  Widget oNhap(
    String nhan,
    TextEditingController c,
    String goiY,
    IconData icon, {
    bool? an,
    VoidCallback? doiAn,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nhan),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            obscureText: an ?? false,
            decoration: InputDecoration(
              hintText: goiY,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
              // chỉ ô mật khẩu mới có nút con mắt
              suffixIcon: an == null
                  ? null
                  : IconButton(
                      icon: Icon(
                        an
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: doiAn,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F3),
      body: Row(
        children: [
          // Bên trái: nền xanh, logo, câu trích dẫn (chỉ hiện khi màn hình rộng)
          if (MediaQuery.of(context).size.width >= 900)
            Expanded(
              child: Container(
                color: const Color(0xFF4F6355),
                padding: const EdgeInsets.all(80),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo ở trên cùng
                    Text(
                      'BookNest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Spacer đẩy phần dưới xuống, Spacer đôi thì chia đều khoảng trống
                    Spacer(),
                    // Câu trích dẫn ở giữa
                    Text(
                      '“Sách là phép màu di động độc nhất vô nhị.”',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '— Stephen King',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Spacer(),
                    // Dòng nhỏ ở dưới cùng
                    Text(
                      'Đọc hôm nay. Dẫn lối ngày mai.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Bên phải: thẻ đăng ký
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 380,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Tạo tài khoản',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          oNhap(
                            'Họ và tên',
                            ten,
                            'Họ và tên',
                            Icons.person_outline,
                          ),
                          oNhap('Email', email, 'email', Icons.mail_outline),
                          oNhap(
                            'Mật khẩu',
                            password,
                            'Mật khẩu',
                            Icons.lock_outline,
                            an: an1,
                            doiAn: () => setState(() => an1 = !an1),
                          ),
                          oNhap(
                            'Xác nhận mật khẩu',
                            xacNhan,
                            'Nhập lại mật khẩu',
                            Icons.lock_outline,
                            an: an2,
                            doiAn: () => setState(() => an2 = !an2),
                          ),

                          if (loi != '')
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                loi,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),

                          ElevatedButton(
                            onPressed: dangTai ? null : dangKy,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF636B62),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              dangTai ? 'Đang đăng ký...' : 'Đăng ký',
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Đã có tài khoản?'),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Đăng nhập'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
