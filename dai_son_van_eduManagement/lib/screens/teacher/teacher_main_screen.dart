import 'package:flutter/material.dart';

import 'teacher_home_screen.dart';
import 'lop_hoc_phan_screen.dart';

class TeacherMainScreen extends StatefulWidget {
  final String hoTen;

  const TeacherMainScreen({super.key, required this.hoTen});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
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
          TeacherHomeScreen(hoTen: widget.hoTen, onTabSelected: _chuyenTab),
          const LopHocPhanScreen(),
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
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: Color(0xFF5140E8)),
            label: 'Lớp phụ trách',
          ),
        ],
      ),
    );
  }
}
