import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class StudentHomeScreen extends StatefulWidget {
  final String hoTen;
  final String maSV;
  final ValueChanged<int> onTabSelected;

  const StudentHomeScreen({
    super.key,
    required this.hoTen,
    required this.maSV,
    required this.onTabSelected,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  static const _mauTim = Color(0xFF5140E8);
  static const _timNhat = Color(0xFFEFEDFF);

  bool _dangDangXuat = false;

  Future<void> _dangXuat() async {
    if (_dangDangXuat) return;

    setState(() => _dangDangXuat = true);

    try {
      await AuthService().dangXuat();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng xuất thất bại. Vui lòng thử lại.')),
      );
    } finally {
      if (mounted) {
        setState(() => _dangDangXuat = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(Icons.school_outlined, color: _mauTim, size: 28),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'EduManagement',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _mauTim,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: _dangDangXuat ? null : _dangXuat,
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),

          Text(
            'Xin chào, ${widget.hoTen}! 👋',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Theo dõi thông tin và kết quả học tập của bạn.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _timNhat,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_outline, color: _mauTim),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sinh viên',
                        style: TextStyle(
                          color: _mauTim,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Mã sinh viên: ${widget.maSV}'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Material(
            color: _mauTim,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => widget.onTabSelected(2),
              child: const Padding(
                padding: EdgeInsets.all(22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kết quả học tập',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Xem điểm theo năm học và học kỳ',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.assessment_outlined,
                        color: _mauTim,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            'Thông tin của bạn',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFE4E4EC)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: const CircleAvatar(
                backgroundColor: _timNhat,
                child: Icon(Icons.badge_outlined, color: _mauTim),
              ),
              title: const Text(
                'Hồ sơ cá nhân',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Xem họ tên, ngày sinh, số điện thoại và lớp',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => widget.onTabSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}
