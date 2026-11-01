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
  final _service = MonHocService();

  late Stream<List<MonHoc>> _monHocStream;
  bool _dangXoa = false;

  @override
  void initState() {
    super.initState();
    _monHocStream = _service.layDanhSach();
  }

  void _thongBao(String noiDung) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(noiDung)));
  }

  Future<void> _moForm({MonHoc? monHoc}) async {
    if (_dangXoa) return;

    final daLuu = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MonHocFormScreen(monHoc: monHoc)),
    );

    if (!mounted || daLuu != true) return;

    _thongBao(monHoc == null ? 'Đã thêm môn học.' : 'Đã cập nhật môn học.');
  }

  Future<void> _xoaMonHoc(MonHoc mon) async {
    if (_dangXoa) return;

    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa môn học?'),
        content: Text(
          'Bạn muốn xóa môn "${mon.tenMon}" (${mon.maMon})?\n\n'
          'Chỉ xóa được môn chưa phân cho lớp học phần.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (!mounted || dongY != true) return;

    setState(() => _dangXoa = true);

    try {
      await _service.xoaMonHoc(mon);

      if (!mounted) return;

      _thongBao('Đã xóa môn học.');
    } catch (e) {
      if (!mounted) return;

      _thongBao(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _dangXoa = false);
      }
    }
  }

  void _thuLai() {
    setState(() {
      _monHocStream = _service.layDanhSach();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách môn học')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _dangXoa ? null : () => _moForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm môn học'),
      ),
      body: Column(
        children: [
          if (_dangXoa) const LinearProgressIndicator(),
          Expanded(
            child: StreamBuilder<List<MonHoc>>(
              stream: _monHocStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Không tải được môn học.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _thuLai,
                            child: const Text('Thử lại'),
                          ),
                        ],
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
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Chưa có môn học. Nhấn “Thêm môn học” để tạo.',
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                        subtitle: Text(
                          '${mon.maMon} · ${mon.soTinChi} tín chỉ',
                        ),
                        trailing: PopupMenuButton<String>(
                          enabled: !_dangXoa,
                          tooltip: 'Thao tác môn học',
                          onSelected: (value) async {
                            if (value == 'sua') {
                              await _moForm(monHoc: mon);
                            } else if (value == 'xoa') {
                              await _xoaMonHoc(mon);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'sua',
                              child: Text('Sửa môn học'),
                            ),
                            PopupMenuItem(
                              value: 'xoa',
                              child: Text('Xóa môn học'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
