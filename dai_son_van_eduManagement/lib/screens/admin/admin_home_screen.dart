import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/sinh_vien_service.dart';
import '../../services/lop_service.dart';
import 'quan_ly_hoc_phan_screen.dart';

import 'sinh_vien_form_screen.dart';
import 'bao_cao_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final String hoTen;
  final ValueChanged<int> onTabSelected;

  const AdminHomeScreen({
    super.key,
    required this.hoTen,
    required this.onTabSelected,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  static const _mauTim = Color(0xFF5140E8);
  static const _timNhat = Color(0xFFEFEDFF);

  late final Stream<int> _soSinhVienStream;
  late final Stream<int> _soLopStream;

  bool _dangDangXuat = false;

  @override
  void initState() {
    super.initState();

    _soSinhVienStream = SinhVienService().layDanhSach().map(
      (danhSach) => danhSach.length,
    );

    _soLopStream = LopService().layDanhSach().map(
      (danhSach) => danhSach.length,
    );
  }

  Future<void> _themSinhVien() async {
    final daLuu = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SinhVienFormScreen()),
    );

    if (!mounted) return;

    if (daLuu == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm sinh viên thành công.')),
      );
    }
  }

  Future<void> _dangXuat() async {
    if (_dangDangXuat) return;

    setState(() {
      _dangDangXuat = true;
    });

    try {
      await AuthService().dangXuat();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng xuất thất bại. Vui lòng thử lại.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _dangDangXuat = false;
        });
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
            tooltip: 'Thống kê và báo cáo',
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BaoCaoScreen()),
              );
            },
          ),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Text(
              'Xin chào, ${widget.hoTen}! 👋',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'Quản lý sinh viên dễ dàng hơn!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _timNhat,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 19,
                    color: _mauTim,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Quản trị viên',
                    style: TextStyle(
                      color: _mauTim,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Thong ke: nhan vao de chuyen tab.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _theThongKe(
                    stream: _soSinhVienStream,
                    icon: Icons.people_outline,
                    nhan: 'Sinh viên',
                    onTap: () => widget.onTabSelected(1),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _theThongKe(
                    stream: _soLopStream,
                    icon: Icons.class_outlined,
                    nhan: 'Lớp hành chính',
                    onTap: () => widget.onTabSelected(2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            _tieuDe('Thao tác nhanh'),

            const SizedBox(height: 14),

            // Them sinh vien van mo form bang Navigator.push.
            Material(
              color: _mauTim,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _themSinhVien,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                'QUẢN LÝ HỒ SƠ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Thêm sinh viên mới',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tạo hồ sơ và chọn lớp cho sinh viên',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_add_alt_1,
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

            _tieuDe('Chức năng quản lý'),

            const SizedBox(height: 14),

            _mucChucNang(
              icon: Icons.badge_outlined,
              ten: 'Danh sách sinh viên',
              moTa: 'Tra cứu, chỉnh sửa và xóa hồ sơ',
              onTap: () => widget.onTabSelected(1),
            ),

            const SizedBox(height: 12),

            _mucChucNang(
              icon: Icons.class_outlined,
              ten: 'Lớp hành chính',
              moTa: 'Xem danh sách và tạo lớp mới',
              onTap: () => widget.onTabSelected(2),
            ),

            const SizedBox(height: 12),

            _mucChucNang(
              icon: Icons.menu_book_outlined,
              ten: 'Môn học',
              moTa: 'Xem danh mục và tạo môn học',
              onTap: () => widget.onTabSelected(3),
            ),

            const SizedBox(height: 12),

            _mucChucNang(
              icon: Icons.school_outlined,
              ten: 'Lớp học phần',
              moTa: 'Phân công giảng viên và thêm sinh viên vào lớp',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuanLyHocPhanScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _tieuDe(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
    );
  }

  Widget _theThongKe({
    required Stream<int> stream,
    required IconData icon,
    required String nhan,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8F8FE),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE4E4EC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 22),
          child: Column(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: _timNhat,
                child: Icon(icon, color: _mauTim, size: 30),
              ),

              const SizedBox(height: 12),

              StreamBuilder<int>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Tooltip(
                      message: 'Không tải được số lượng',
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  return Text(
                    '${snapshot.data}',
                    style: const TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

              const SizedBox(height: 4),

              Text(
                nhan,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mucChucNang({
    required IconData icon,
    required String ten,
    required String moTa,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE4E4EC)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _timNhat,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _mauTim, size: 26),
        ),
        title: Text(
          ten,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(moTa),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
