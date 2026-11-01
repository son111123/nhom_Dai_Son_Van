import 'package:flutter/material.dart';

import '../../models/mon_hoc.dart';
import '../../services/mon_hoc_service.dart';
import 'mon_hoc_form_screen.dart';

class MonHocListScreen extends StatefulWidget {
  const MonHocListScreen({super.key});

  @override
  State<MonHocListScreen> createState() => _MonHocListScreenState();
}

class _MonHocListScreenState extends State<MonHocListScreen> {
  late final Stream<List<MonHoc>> _monHocStream;

  @override
  void initState() {
    super.initState();
    _monHocStream = MonHocService().layDanhSach();
  }

  Future<void> _moFormThem() async {
    final daThem = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MonHocFormScreen()),
    );

    if (!mounted) return;

    if (daThem == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thêm môn học thành công')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách môn học')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _moFormThem,
        icon: const Icon(Icons.add),
        label: const Text('Thêm môn học'),
      ),
      body: StreamBuilder<List<MonHoc>>(
        stream: _monHocStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Không tải được môn học.\n${snapshot.error}',
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
              child: Text('Chưa có môn học. Nhấn “Thêm môn học” để tạo.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: danhSach.length,
            itemBuilder: (context, index) {
              final mon = danhSach[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.menu_book_outlined),
                  ),
                  title: Text(
                    mon.tenMon,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Mã môn: ${mon.maMon}'),
                  trailing: Text(
                    '${mon.soTinChi} tín chỉ',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
