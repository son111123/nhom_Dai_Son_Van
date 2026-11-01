import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/hoc_phan_service.dart';
import '../shared/thoi_khoa_bieu_screen.dart';
import 'danh_sach_diem_screen.dart';
import 'buoi_hoc_screen.dart';

class LopHocPhanScreen extends StatefulWidget {
  const LopHocPhanScreen({super.key});

  @override
  State<LopHocPhanScreen> createState() => _LopHocPhanScreenState();
}

class _LopHocPhanScreenState extends State<LopHocPhanScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _lopStream;

  @override
  void initState() {
    super.initState();

    _lopStream = HocPhanService().layLopPhuTrach();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lớp học phần phụ trách'),
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
                    content: Text('Đăng xuất thất bại. Hãy thử lại.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _lopStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Không tải được lớp học phần.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final danhSach = snapshot.data!.docs;

          if (danhSach.isEmpty) {
            return const Center(
              child: Text('Bạn chưa được phân công lớp học phần.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: danhSach.length,
            itemBuilder: (context, index) {
              final doc = danhSach[index];
              final data = doc.data();

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.school_outlined),
                  ),
                  title: Text('${doc.id} — ${data['tenMon']}'),
                  subtitle: Text('Học kỳ ${data['hocKy']} · ${data['namHoc']}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final luaChon = await showDialog<String>(
                      context: context,
                      builder: (dialogContext) {
                        return SimpleDialog(
                          title: Text('Lớp ${doc.id}'),
                          children: [
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(dialogContext, 'lichHoc');
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Xem thời khóa biểu'),
                              ),
                            ),
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(dialogContext, 'bangDiem');
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.grade_outlined),
                                    SizedBox(width: 12),
                                    Text('Bảng điểm'),
                                  ],
                                ),
                              ),
                            ),
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(dialogContext, 'diemDanh');
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.fact_check_outlined),
                                    SizedBox(width: 12),
                                    Text('Điểm danh'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (!context.mounted || luaChon == null) {
                      return;
                    }

                    final tenMon = data['tenMon'] as String? ?? '';

                    if (luaChon == 'lichHoc') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ThoiKhoaBieuScreen(
                            vaiTro: 'teacher',
                            maLHP: doc.id,
                          ),
                        ),
                      );
                    } else if (luaChon == 'diemDanh') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BuoiHocScreen(maLHP: doc.id, tenMon: tenMon),
                        ),
                      );
                    } else if (luaChon == 'bangDiem') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DanhSachDiemScreen(maLHP: doc.id, tenMon: tenMon),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
