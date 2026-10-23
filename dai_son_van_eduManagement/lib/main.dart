import 'package:flutter/material.dart';

import 'tongquan.dart';
import 'sinhvien.dart';
import 'lophoc.dart';
import 'hoso.dart';

void main() {
  runApp(const EduManageApp());
}

class EduManageApp extends StatelessWidget {
  const EduManageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduManager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';

  final List<Student> _students = [
    Student(
      id: '1',
      name: 'Nguyễn Minh Anh',
      email: 'minhanh@univ.edu.vn',
      classCode: 'CNTT K68-A',
      score: 8.7,
      status: 'Đang học',
    ),
    Student(
      id: '2',
      name: 'Trần Gia Huy',
      email: 'giahuy@univ.edu.vn',
      classCode: 'Kinh tế K67-B',
      score: 8.2,
      status: 'Đang học',
    ),
    Student(
      id: '3',
      name: 'Lê Hoàng Nam',
      email: 'hoangnam@univ.edu.vn',
      classCode: 'CNTT K68-A',
      score: 7.9,
      status: 'Đang học',
    ),
    Student(
      id: '4',
      name: 'Phạm Thu Hà',
      email: 'thuha@univ.edu.vn',
      classCode: 'Marketing K66',
      score: 8.5,
      status: 'Tạm nghỉ',
      isInactive: true,
    ),
  ];

  final List<ClassInfo> _classes = [
    ClassInfo(
      id: '1',
      title: 'CNTT K68-A',
      subtitle: 'Lập trình ứng dụng',
      teacherName: 'TS. Nguyễn Văn Long',
      teacherAvatar: 'VL',
      studentCount: 42,
      room: 'A305',
      progress: 0.68,
      tag: 'CNTT-68A',
    ),
    ClassInfo(
      id: '2',
      title: 'Kinh tế K67-B',
      subtitle: 'Kinh tế vi mô',
      teacherName: 'ThS. Lê Thu Trang',
      teacherAvatar: 'TT',
      studentCount: 38,
      room: 'B201',
      progress: 0.54,
      tag: 'KT-67B',
    ),
  ];

  void _addStudent(Student student) {
    setState(() => _students.insert(0, student));
  }

  void _addClass(ClassInfo newClass) {
    setState(() => _classes.insert(0, newClass));
  }

  void _updateStudentScore(String id, double newScore) {
    setState(() {
      final index = _students.indexWhere((s) => s.id == id);
      if (index != -1) {
        _students[index] = _students[index].copyWith(score: newScore);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _students.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(query) ||
          s.email.toLowerCase().contains(query) ||
          s.classCode.toLowerCase().contains(query);
    }).toList();

    final List<Widget> screens = [
      OverviewTab(students: _students, classes: _classes),
      StudentsTab(
        students: filteredStudents,
        onAddStudent: _addStudent,
        onUpdateScore: _updateStudentScore,
        onSearchChanged: (val) => setState(() => _searchQuery = val),
      ),
      ClassesTab(classes: _classes, students: _students, onAddClass: _addClass),
      const ProfileTab(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: screens),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              label: 'Sinh viên',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Lớp học',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
}
