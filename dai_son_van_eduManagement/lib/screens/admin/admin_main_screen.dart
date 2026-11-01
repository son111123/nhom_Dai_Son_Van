import 'package:flutter/material.dart';

import 'admin_home_screen.dart';
import 'sinh_vien_list_screen.dart';
import 'lop_list_screen.dart';
import 'mon_hoc_list_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final String hoTen;

  const AdminMainScreen({super.key, required this.hoTen});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
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
          AdminHomeScreen(hoTen: widget.hoTen, onTabSelected: _chuyenTab),
          const SinhVienListScreen(),
          const LopListScreen(),
          const MonHocListScreen(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabHienTai,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8E5FF),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        onDestinationSelected: _chuyenTab,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF5140E8)),
            label: 'Trang chủ',
          ),

          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Color(0xFF5140E8)),
            label: 'Sinh viên',
          ),

          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_, color: Color(0xFF5140E8)),
            label: 'Lớp',
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF5140E8)),
            label: 'Môn học',
          ),
        ],
      ),
    );
  }
}
