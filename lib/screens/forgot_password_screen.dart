import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

const _green = Color(0xFF566A5C);

class ForgotPasswordScreen extends StatefulWidget {
  // Có thể truyền sẵn email từ trang đăng nhập
  final String initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  bool _loading = false;
  bool _sent = false; // đã gửi mail -> hiện màn hình thông báo
  String? _error;

  // Chống bấm gửi lại liên tục
  static const _cooldownSeconds = 60;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService().sendPasswordReset(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _sent = true;
        _loading = false;
      });
      _startCooldown();
      return;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          _error = 'Email không hợp lệ';
          break;
        case 'user-not-found':
          _error = 'Không tìm thấy tài khoản với email này';
          break;
        case 'too-many-requests':
          _error = 'Bạn thử quá nhiều lần, vui lòng đợi một lúc rồi thử lại';
          break;
        case 'network-request-failed':
          _error = 'Lỗi kết nối mạng, vui lòng kiểm tra lại';
          break;
        default:
          _error = 'Không gửi được email, vui lòng thử lại';
      }
    } catch (_) {
      _error = 'Đã có lỗi xảy ra, vui lòng thử lại';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      body: Row(
        children: [
          // Nửa trái: chỉ hiện khi màn hình rộng (giống trang đăng nhập)
          if (wide)
            Expanded(
              flex: 2,
              child: Container(
                color: const Color(0xFF4F6355),
                padding: const EdgeInsets.all(64),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BookNest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.lock_reset, color: Colors.white, size: 72),
                    SizedBox(height: 24),
                    Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Chúng tôi sẽ gửi liên kết giúp bạn đặt lại mật khẩu.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),

          // Nửa phải
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _sent ? _buildSent() : _buildForm(),
                      ),
                    ),
                  ),
                ),
                // Nút quay lại
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      tooltip: 'Quay lại',
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
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

  // ---------- Form nhập email ----------
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Quên mật khẩu',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhập email đã đăng ký, chúng tôi sẽ gửi liên kết đặt lại mật khẩu cho bạn.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return 'Vui lòng nhập email';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
            onFieldSubmitted: (_) => _loading ? null : _send(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Gửi liên kết đặt lại',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Quay lại đăng nhập',
              style: TextStyle(color: _green),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Màn hình sau khi đã gửi ----------
  Widget _buildSent() {
    return Column(
      key: const ValueKey('sent'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 64, color: _green),
        const SizedBox(height: 24),
        const Text(
          'Kiểm tra email của bạn',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Chúng tôi đã gửi liên kết đặt lại mật khẩu tới\n${_emailCtrl.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nếu không thấy email, hãy kiểm tra cả thư mục Spam.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black45, fontSize: 13),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Quay lại đăng nhập',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: (_cooldown > 0 || _loading) ? null : _send,
          child: Text(
            _cooldown > 0
                ? 'Gửi lại email (${_cooldown}s)'
                : 'Chưa nhận được? Gửi lại',
            style: TextStyle(color: _cooldown > 0 ? Colors.black38 : _green),
          ),
        ),
        TextButton(
          onPressed: () => setState(() {
            _sent = false;
            _error = null;
          }),
          child: const Text('Dùng email khác', style: TextStyle(color: _green)),
        ),
      ],
    );
  }
}
