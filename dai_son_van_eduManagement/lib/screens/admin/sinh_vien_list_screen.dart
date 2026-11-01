import 'package:flutter/material.dart';

import '../../models/sinh_vien.dart';
import '../../services/sinh_vien_service.dart';
import 'sinh_vien_form_screen.dart';
import 'sinh_vien_detail_screen.dart';

class SinhVienListScreen extends StatefulWidget {
  const SinhVienListScreen({super.key});

  @override
  State<SinhVienListScreen> createState() => _SinhVienListScreenState();
}

class _SinhVienListScreenState extends State<SinhVienListScreen> {
  final _service = SinhVienService();

  late final Stream<List<SinhVien>> _sinhVienStream;

  String _tuKhoa = '';
  bool _dangXoa = false;

  @override
  void initState() {
    super.initState();
    _sinhVienStream = _service.layDanhSach();
  }

  void _thongBao(String noiDung) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(noiDung)));
  }

  Future<void> _moForm({SinhVien? sinhVien}) async {
    final daLuu = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SinhVienFormScreen(sinhVien: sinhVien)),
    );

    if (!mounted) return;

    if (daLuu == true) {
      _thongBao('Đã lưu thông tin sinh viên.');
    }
  }

  Future<void> _xoa(SinhVien sv) async {
    if (_dangXoa) return;

    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa hồ sơ sinh viên?'),
          content: Text('Bạn có muốn xóa ${sv.maSV} — ${sv.hoTen} không?'),
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
        );
      },
    );

    if (dongY != true || !mounted) return;

    setState(() => _dangXoa = true);

    try {
      await _service.xoa(sv.maSV);

      if (!mounted) return;
      _thongBao('Đã xóa hồ sơ sinh viên.');
    } catch (e) {
      if (!mounted) return;
      _thongBao('Không xóa được: $e');
    } finally {
      if (mounted) {
        setState(() => _dangXoa = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách sinh viên')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _moForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm sinh viên'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm chính xác theo mã sinh viên',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _tuKhoa = value.trim().toUpperCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<List<SinhVien>>(
              stream: _sinhVienStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Không tải được danh sách.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final danhSach = snapshot.data!.where((sv) {
                  return _tuKhoa.isEmpty || sv.maSV == _tuKhoa;
                }).toList();

                if (danhSach.isEmpty) {
                  return const Center(
                    child: Text('Không có sinh viên phù hợp.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: danhSach.length,
                  itemBuilder: (context, index) {
                    final sv = danhSach[index];

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(sv.hoTen),
                        subtitle: Text('${sv.maSV} · Lớp: ${sv.maLop}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SinhVienDetailScreen(maSV: sv.maSV),
                            ),
                          );
                        },
                        trailing: PopupMenuButton<String>(
                          enabled: !_dangXoa,
                          onSelected: (value) {
                            if (value == 'sua') {
                              _moForm(sinhVien: sv);
                            } else if (value == 'xoa') {
                              _xoa(sv);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'sua',
                              child: Text('Sửa / Xếp lớp'),
                            ),
                            PopupMenuItem(value: 'xoa', child: Text('Xóa')),
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
