import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/hoc_phan_service.dart';

class TeacherHomeScreen extends StatefulWidget {
  final String hoTen;
  final ValueChanged<int> onTabSelected;

  const TeacherHomeScreen({
    super.key,
    required this.hoTen,
    required this.onTabSelected,
  });

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  static const _mauTim = Color(0xFF5140E8);
  static const _timNhat = Color(0xFFEFEDFF);

  late final Stream<int> _soLopStream;

  bool _dangDangXuat = false;

  @override
  void initState() {
    super.initState();

    _soLopStream = HocPhanService().layLopPhuTrach().map(
      (snapshot) => snapshot.docs.length,
    );
  }

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
            'Theo dõi lớp học và cập nhật kết quả sinh viên.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _timNhat,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.badge_outlined, color: _mauTim, size: 19),
                  SizedBox(width: 6),
                  Text(
                    'Giảng viên',
                    style: TextStyle(
                      color: _mauTim,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tong so lop duoc phan cong, bao gom cac hoc ky.
          Material(
            color: const Color(0xFFF8F8FE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Color(0xFFE4E4EC)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => widget.onTabSelected(1),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: _timNhat,
                      child: Icon(
                        Icons.school_outlined,
                        color: _mauTim,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lớp học phần được phân công',
                            style: TextStyle(fontSize: 15),
                          ),

                          const SizedBox(height: 8),

                          StreamBuilder<int>(
                            stream: _soLopStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Text(
                                  'Không tải được số lượng',
                                  style: TextStyle(color: Colors.red),
                                );
                              }

                              if (!snapshot.hasData) {
                                return const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }

                              return Text(
                                '${snapshot.data} lớp',
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: _mauTim,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Tất cả học kỳ',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            'Quản lý giảng dạy',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          Material(
            color: _mauTim,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => widget.onTabSelected(1),
              child: const Padding(
                padding: EdgeInsets.all(22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lớp học phần của tôi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Xem sinh viên, nhập và chỉnh sửa điểm',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit_note, color: _mauTim, size: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Chọn một lớp học phần để xem danh sách sinh viên '
            'và cập nhật điểm.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
