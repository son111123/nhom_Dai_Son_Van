import 'package:flutter/material.dart';

import '../shared/thoi_khoa_bieu_screen.dart';
import 'student_home_screen.dart';
import 'ho_so_screen.dart';
import 'ket_qua_screen.dart';

class StudentMainScreen extends StatefulWidget {
  final String hoTen;
  final String maSV;

  const StudentMainScreen({super.key, required this.hoTen, required this.maSV});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _tabHienTai = 0;

  void _chuyenTab(int index) {
    setState(() {
      _tabHienTai = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabHienTai,
        children: [
          StudentHomeScreen(
            hoTen: widget.hoTen,
            maSV: widget.maSV,
            onTabSelected: _chuyenTab,
          ),
          HoSoScreen(maSV: widget.maSV),
          KetQuaScreen(maSV: widget.maSV),
          ThoiKhoaBieuScreen(vaiTro: 'student', maSV: widget.maSV),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabHienTai,
        onDestinationSelected: _chuyenTab,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFE8E5FF),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF5140E8)),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF5140E8)),
            label: 'Hồ sơ',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment, color: Color(0xFF5140E8)),
            label: 'Kết quả',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch học',
          ),
        ],
      ),
    );
  }
}
