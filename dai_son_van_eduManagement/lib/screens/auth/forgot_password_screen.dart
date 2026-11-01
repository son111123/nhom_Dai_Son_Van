import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String emailBanDau;

  const ForgotPasswordScreen({super.key, this.emailBanDau = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late final TextEditingController _emailController;

  bool _dangGui = false;
  bool _daGui = false;
  String? _loi;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController(text: widget.emailBanDau);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _guiEmail() async {
    if (_dangGui || _daGui) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _dangGui = true;
      _loi = null;
    });

    try {
      await _authService.quenMatKhau(_emailController.text);

      if (!mounted) return;

      setState(() {
        _daGui = true;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _loi = 'Email không đúng định dạng.';
            break;
          case 'network-request-failed':
            _loi = 'Không có kết nối mạng.';
            break;
          case 'too-many-requests':
            _loi = 'Bạn gửi yêu cầu quá nhiều lần. Hãy thử lại sau.';
            break;
          default:
            _loi = 'Không gửi được yêu cầu. Mã lỗi: ${e.code}';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loi = 'Có lỗi xảy ra. Vui lòng thử lại.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _dangGui = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_reset,
                    size: 72,
                    color: Color(0xFF5140E8),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Đặt lại mật khẩu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nhập email đã đăng ký để nhận hướng dẫn '
                    'đặt lại mật khẩu.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_dangGui && !_daGui,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _guiEmail(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(email)) {
                        return 'Nhập email hợp lệ';
                      }

                      return null;
                    },
                  ),
                  if (_loi != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _loi!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (_daGui) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Nếu email này có tài khoản phù hợp, '
                      'bạn sẽ nhận được hướng dẫn đặt lại mật khẩu. '
                      'Hãy kiểm tra cả thư mục thư rác.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _dangGui || _daGui ? null : _guiEmail,
                      child: Text(
                        _dangGui
                            ? 'Đang gửi...'
                            : _daGui
                            ? 'Đã tiếp nhận yêu cầu'
                            : 'Gửi yêu cầu',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại đăng nhập'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
