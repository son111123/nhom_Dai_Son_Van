import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailControler = TextEditingController();
  final _passwordControler = TextEditingController();
  final _authService = AuthService();

  bool _dangXuLy = false;
  bool _anMatKhau = true;

  @override
  void dispose() {
    _emailControler.dispose();
    _passwordControler.dispose();
    super.dispose();
  }

  Future<void> _dangNhap() async {
    if (_dangXuLy) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _dangXuLy = true;
    });

    try {
      await _authService.dangNhap(
        _emailControler.text,
        _passwordControler.text,
      );

      // RoleGate tu chuyen man hinh khi dang nhap thanh cong.
    } on FirebaseAuthException catch (e) {
      String thongBao;

      switch (e.code) {
        case 'invalid-email':
          thongBao = 'Email không đúng định dạng.';
          break;

        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          thongBao = 'Email hoặc mật khẩu không chính xác.';
          break;

        case 'user-disabled':
          thongBao = 'Tài khoản đã bị khóa.';
          break;

        case 'too-many-requests':
          thongBao = 'Thử đăng nhập quá nhiều lần. Vui lòng thử lại sau.';
          break;

        case 'network-request-failed':
          thongBao = 'Không có kết nối mạng.';
          break;

        default:
          thongBao = 'Không đăng nhập được. Mã lỗi: ${e.code}';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(thongBao)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra. Vui lòng thử lại.')),
      );
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
    return Scaffold(
      body: SafeArea(
        child: Center(
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
                      Icons.shop_outlined,
                      size: 80.0,
                      color: Color(0xFF5140E8),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'EduManagement',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5140E8),
                      ),
                    ),

                    const SizedBox(height: 32),

                    //Nhap email
                    TextFormField(
                      controller: _emailControler,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Vui lòng nhập email';
                        }

                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Email không đúng định dạng';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    //Nhap mat khau
                    TextFormField(
                      controller: _passwordControler,
                      obscureText: _anMatKhau,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _dangNhap(),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixIcon: IconButton(
                          tooltip: _anMatKhau ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                          icon: Icon(
                            _anMatKhau
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _anMatKhau = !_anMatKhau;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _dangXuLy ? null : _dangNhap,
                        child: Text(
                          _dangXuLy ? 'Đang đăng nhập...' : 'Đăng nhập',
                          style: const TextStyle(fontSize: 16),
                        ),
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
