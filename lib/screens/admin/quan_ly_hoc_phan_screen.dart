import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/quan_ly_hoc_phan_service.dart';
import 'hoc_phan_form_screen.dart';

class QuanLyHocPhanScreen extends StatefulWidget {
  const QuanLyHocPhanScreen({super.key});

  @override
  State<QuanLyHocPhanScreen> createState() => _QuanLyHocPhanScreenState();
}

class _QuanLyHocPhanScreenState extends State<QuanLyHocPhanScreen> {
  final _service = QuanLyHocPhanService();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _lopStream;

  @override
  void initState() {
    super.initState();
    _lopStream = _service.layDanhSach();
  }

  Future<void> _taoLop() async {
    final daTao = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const HocPhanFormScreen()),
    );

    if (!mounted) return;

    if (daTao == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã tạo lớp học phần.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý lớp học phần')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _taoLop,
        icon: const Icon(Icons.add),
        label: const Text('Tạo lớp'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _lopStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Không tải được lớp:\n${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final danhSach = snapshot.data!.docs;

          if (danhSach.isEmpty) {
            return const Center(child: Text('Chưa có lớp học phần.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: danhSach.length,
            itemBuilder: (context, index) {
              final doc = danhSach[index];
              final data = doc.data();

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${doc.id} — ${data['tenMon']}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Học kỳ ${data['hocKy']} · ${data['namHoc']}'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DanhSachGhiDanhScreen(maLHP: doc.id),
                                ),
                              );
                            },
                            child: const Text('Xem danh sách'),
                          ),
                          FilledButton(
                            onPressed: () async {
                              final daThem = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => GhiDanhDialog(maLHP: doc.id),
                              );

                              if (!context.mounted) return;

                              if (daThem == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã thêm sinh viên vào lớp.'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Thêm sinh viên'),
                          ),
                        ],
                      ),
                    ],
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

class GhiDanhDialog extends StatefulWidget {
  final String maLHP;

  const GhiDanhDialog({super.key, required this.maLHP});

  @override
  State<GhiDanhDialog> createState() => _GhiDanhDialogState();
}

class _GhiDanhDialogState extends State<GhiDanhDialog> {
  final _maController = TextEditingController();

  bool _dangLuu = false;
  String? _loi;

  @override
  void dispose() {
    _maController.dispose();
    super.dispose();
  }

  Future<void> _luu() async {
    if (_dangLuu) return;

    setState(() {
      _dangLuu = true;
      _loi = null;
    });

    try {
      await QuanLyHocPhanService().ghiDanh(
        maLHP: widget.maLHP,
        maSV: _maController.text,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loi = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _dangLuu = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dangLuu,
      child: AlertDialog(
        title: Text('Thêm sinh viên vào ${widget.maLHP}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _maController,
                enabled: !_dangLuu,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Mã sinh viên đã có',
                  hintText: 'Ví dụ: SV001',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_loi != null) ...[
                const SizedBox(height: 12),
                Text(
                  _loi!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _dangLuu ? null : () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: _dangLuu ? null : _luu,
            child: Text(_dangLuu ? 'Đang lưu...' : 'Thêm vào lớp'),
          ),
        ],
      ),
    );
  }
}

class DanhSachGhiDanhScreen extends StatefulWidget {
  final String maLHP;

  const DanhSachGhiDanhScreen({super.key, required this.maLHP});

  @override
  State<DanhSachGhiDanhScreen> createState() => _DanhSachGhiDanhScreenState();
}

class _DanhSachGhiDanhScreenState extends State<DanhSachGhiDanhScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();

    _stream = FirebaseFirestore.instance
        .collection('ketQua')
        .where('maLHP', isEqualTo: widget.maLHP)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sinh viên · ${widget.maLHP}')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final danhSach = snapshot.data!.docs;

          if (danhSach.isEmpty) {
            return const Center(child: Text('Chưa có sinh viên trong lớp.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: danhSach.map((doc) {
              final data = doc.data();

              return Card(
                child: ListTile(
                  title: Text('${data['maSV']} — ${data['hoTen']}'),
                  subtitle: Text('Điểm: ${data['diem'] ?? 'Chưa có điểm'}'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
