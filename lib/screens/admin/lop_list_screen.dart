import 'package:flutter/material.dart';

import '../../models/lop_hanh_chinh.dart';
import '../../services/lop_service.dart';
import 'lop_form_screen.dart';

class LopListScreen extends StatefulWidget {
  const LopListScreen({super.key});

  @override
  State<LopListScreen> createState() => _LopListScreenState();
}

class _LopListScreenState extends State<LopListScreen> {
  final _lopService = LopService();

  late final Stream<List<LopHanhChinh>> _lopStream;

  @override
  void initState() {
    super.initState();
    _lopStream = _lopService.layDanhSach();
  }

  Future<void> _moFormThemLop() async {
    final daThem = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LopFormScreen()),
    );

    if (!mounted) return;

    if (daThem == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Thêm lớp thành công')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lớp hành chính')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _moFormThemLop,
        icon: const Icon(Icons.add),
        label: const Text('Thêm lớp'),
      ),
      body: StreamBuilder<List<LopHanhChinh>>(
        stream: _lopStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Không tải được danh sách lớp.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final danhSach = snapshot.data!;

          if (danhSach.isEmpty) {
            return const Center(
              child: Text('Chưa có lớp. Nhấn “Thêm lớp” để tạo.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: danhSach.length,
            itemBuilder: (context, index) {
              final lop = danhSach[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.class_outlined),
                  ),
                  title: Text(
                    lop.tenLop,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Mã lớp: ${lop.maLop}\nKhóa học: ${lop.khoaHoc}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
