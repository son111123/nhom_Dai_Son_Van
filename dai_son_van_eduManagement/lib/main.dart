import 'package:flutter/material.dart';

import 'tongquan.dart';
import 'sinhvien.dart';
import 'lophoc.dart';
import 'hoso.dart';

void main() {
  runApp(const EduManageApp());
}

class EduManageApp extends StatefulWidget {
  const EduManageApp({super.key});

  @override
  State<EduManageApp> createState() => _EduManageAppState();
}

class _EduManageAppState extends State<EduManageApp> {
  final Map<String, String> _accounts = {'admin': 'admin123'};
  String? _currentUsername;

  bool _login(String username, String password) {
    final normalizedUsername = username.trim().toLowerCase();
    if (_accounts[normalizedUsername] != password) return false;
    setState(() => _currentUsername = normalizedUsername);
    return true;
  }

  bool _register(String username, String password) {
    final normalizedUsername = username.trim().toLowerCase();
    if (_accounts.containsKey(normalizedUsername)) return false;
    setState(() {
      _accounts[normalizedUsername] = password;
      _currentUsername = normalizedUsername;
    });
    return true;
  }

  void _logout() {
    setState(() => _currentUsername = null);
  }

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
      home: _currentUsername == null
          ? AuthScreen(onLogin: _login, onRegister: _register)
          : MainNavigationScreen(
              username: _currentUsername!,
              onLogout: _logout,
            ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final bool Function(String username, String password) onLogin;
  final bool Function(String username, String password) onRegister;

  const AuthScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final succeeded = _isRegistering
        ? widget.onRegister(username, password)
        : widget.onLogin(username, password);

    if (!succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRegistering
                ? 'Tên đăng nhập đã được sử dụng.'
                : 'Tên đăng nhập hoặc mật khẩu không đúng.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegistering ? 'Đăng ký' : 'Đăng nhập';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: 48,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRegistering
                              ? 'Tạo tài khoản để sử dụng EduManager.'
                              : 'Đăng nhập để tiếp tục.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Tên đăng nhập',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final username = value?.trim() ?? '';
                            if (username.isEmpty) {
                              return 'Vui lòng nhập tên đăng nhập.';
                            }
                            if (username.length < 3) {
                              return 'Tên đăng nhập cần ít nhất 3 ký tự.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: _isRegistering
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu.';
                            }
                            if (_isRegistering && value.length < 6) {
                              return 'Mật khẩu cần ít nhất 6 ký tự.';
                            }
                            return null;
                          },
                        ),
                        if (_isRegistering) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmation,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Nhập lại mật khẩu',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscureConfirmation =
                                      !_obscureConfirmation,
                                ),
                                icon: Icon(
                                  _obscureConfirmation
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Mật khẩu nhập lại không khớp.';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 20                        ),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(title),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _isRegistering = !_isRegistering;
                            _formKey.currentState?.reset();
                          }),
                          child: Text(
                            _isRegistering
                                ? 'Đã có tài khoản? Đăng nhập'
                                : 'Chưa có tài khoản? Đăng ký',
                          ),
                        ),
                        if (!_isRegistering)
                          const Text(
                            'Tài khoản mặc định: admin / admin123',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final String username;
  final VoidCallback onLogout;

  const MainNavigationScreen({
    super.key,
    required this.username,
    required this.onLogout,
  });

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
      ProfileTab(
        username: widget.username,
        onLogout: widget.onLogout,
      ),
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
