import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/hoc_phan_service.dart';
import 'danh_sach_diem_screen.dart';

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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DanhSachDiemScreen(
                          maLHP: doc.id,
                          tenMon: data['tenMon'] as String,
                        ),
                      ),
                    );
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
