import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../admin/admin_main_screen.dart';
import '../teacher/teacher_main_screen.dart';
import '../student/student_main_screen.dart';

import 'login_screen.dart';

class RoleGate extends StatefulWidget {
  const RoleGate({super.key});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  final _authService = AuthService();
  late final Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = _authService.theoDoiDangNhap();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Không thể kiểm tra phiên đăng nhập.')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return TaiKhoanGate(key: ValueKey(user.uid), uid: user.uid);
      },
    );
  }
}

class TaiKhoanGate extends StatefulWidget {
  final String uid;

  const TaiKhoanGate({super.key, required this.uid});

  @override
  State<TaiKhoanGate> createState() => _TaiKhoanGateState();
}

class _TaiKhoanGateState extends State<TaiKhoanGate> {
  final _authService = AuthService();

  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _taiKhoanStream;

  @override
  void initState() {
    super.initState();
    _taiKhoanStream = _authService.theoDoiTaiKhoan(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _taiKhoanStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const TrangVaiTro(
            tieuDe: 'Không đọc được tài khoản',
            noiDung: 'Kiểm tra kết nối mạng và Firestore Rules.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data();

        if (data == null) {
          return const TrangVaiTro(
            tieuDe: 'Chưa có hồ sơ tài khoản',
            noiDung: 'Hãy tạo users/UID tương ứng trong Firestore.',
          );
        }

        final hoTen = data['hoTen'] is String ? data['hoTen'] as String : 'bạn';

        switch (data['role']) {
          case 'admin':
            return AdminMainScreen(hoTen: hoTen);

          case 'teacher':
            return TeacherMainScreen(hoTen: hoTen);

          case 'student':
            final maSV = data['maSV'];

            if (maSV is! String ||
                !RegExp(r'^[A-Z0-9_-]{1,30}$').hasMatch(maSV)) {
              return const TrangVaiTro(
                tieuDe: 'Chưa liên kết hồ sơ sinh viên',
                noiDung: 'Hãy bổ sung maSV hợp lệ trong users/UID.',
              );
            }

            return StudentMainScreen(hoTen: hoTen, maSV: maSV);
          default:
            return const TrangVaiTro(
              tieuDe: 'Vai trò không hợp lệ',
              noiDung: 'role phải là admin, teacher hoặc student.',
            );
        }
      },
    );
  }
}

// Man hinh tam, se thay bang cac trang chuc nang sau.
class TrangVaiTro extends StatelessWidget {
  final String tieuDe;
  final String noiDung;

  const TrangVaiTro({super.key, required this.tieuDe, required this.noiDung});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tieuDe),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await AuthService().dangXuat();
              } catch (_) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đăng xuất thất bại. Vui lòng thử lại.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            noiDung,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
