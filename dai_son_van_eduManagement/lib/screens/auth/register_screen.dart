import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _nhapLaiController = TextEditingController();

  final _authService = AuthService();

  bool _dangXuLy = false;
  bool _anMatKhau = true;
  String? _loi;

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _matKhauController.dispose();
    _nhapLaiController.dispose();
    super.dispose();
  }

  Future<void> _dangKy() async {
    if (_dangXuLy) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _dangXuLy = true;
      _loi = null;
    });

    try {
      await _authService.dangKy(
        hoTen: _hoTenController.text,
        email: _emailController.text,
        matKhau: _matKhauController.text,
      );

      if (!mounted) return;

      // Firebase tu dang nhap sau khi dang ky.
      // Quay ve route goc de RoleGate hien thi trang cho duyet.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _loi = 'Email đã được sử dụng.';
            break;
          case 'invalid-email':
            _loi = 'Email không đúng định dạng.';
            break;
          case 'weak-password':
            _loi = 'Mật khẩu chưa đáp ứng yêu cầu bảo mật của hệ thống.';
            break;
          case 'operation-not-allowed':
            _loi = 'Chưa bật đăng nhập Email/Password trên Firebase.';
            break;
          case 'network-request-failed':
            _loi = 'Không có kết nối mạng.';
            break;
          case 'too-many-requests':
            _loi = 'Thao tác quá nhiều lần. Vui lòng thử lại sau.';
            break;
          default:
            _loi = 'Không đăng ký được. Mã lỗi: ${e.code}';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loi = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _dangXuLy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dangXuLy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Đăng ký tài khoản')),
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
                      Icons.person_add_alt_1,
                      size: 64,
                      color: Color(0xFF5140E8),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tạo tài khoản EduManagement',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sau khi đăng ký, quản trị viên sẽ cấp quyền '
                      'và liên kết hồ sơ cho bạn.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _hoTenController,
                      enabled: !_dangXuLy,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final ten = value?.trim() ?? '';

                        if (ten.isEmpty || ten.length > 100) {
                          return 'Nhập họ tên từ 1 đến 100 ký tự';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_dangXuLy,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _matKhauController,
                      enabled: !_dangXuLy,
                      obscureText: _anMatKhau,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: _dangXuLy
                              ? null
                              : () {
                                  setState(() {
                                    _anMatKhau = !_anMatKhau;
                                  });
                                },
                          icon: Icon(
                            _anMatKhau
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Mật khẩu cần ít nhất 6 ký tự';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nhapLaiController,
                      enabled: !_dangXuLy,
                      obscureText: _anMatKhau,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _dangKy(),
                      decoration: const InputDecoration(
                        labelText: 'Nhập lại mật khẩu',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != _matKhauController.text) {
                          return 'Mật khẩu nhập lại không khớp';
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _dangXuLy ? null : _dangKy,
                        child: Text(_dangXuLy ? 'Đang đăng ký...' : 'Đăng ký'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
