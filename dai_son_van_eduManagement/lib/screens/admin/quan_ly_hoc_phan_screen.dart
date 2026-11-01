import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/quan_ly_hoc_phan_service.dart';
import 'hoc_phan_form_screen.dart';
import 'tao_lich_hoc_screen.dart';

class QuanLyHocPhanScreen extends StatefulWidget {
  const QuanLyHocPhanScreen({super.key});

  @override
  State<QuanLyHocPhanScreen> createState() => _QuanLyHocPhanScreenState();
}

class _QuanLyHocPhanScreenState extends State<QuanLyHocPhanScreen> {
  final _service = QuanLyHocPhanService();

  late Stream<QuerySnapshot<Map<String, dynamic>>> _lopStream;

  @override
  void initState() {
    super.initState();
    _lopStream = _service.layDanhSach();
  }

  void _thuLai() {
    setState(() {
      _lopStream = _service.layDanhSach();
    });
  }

  Future<void> _taoLop() async {
    final daTao = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const HocPhanFormScreen()),
    );

    if (!mounted || daTao != true) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã tạo lớp học phần.')));
  }

  Future<void> _moTaoLich({
    required String maLHP,
    required String tenMon,
  }) async {
    final daTao = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TaoLichHocScreen(maLHP: maLHP, tenMon: tenMon),
      ),
    );

    if (!mounted || daTao != true) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã tạo lịch học.')));
  }

  Future<void> _moGhiDanh(String maLHP) async {
    final daThem = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GhiDanhDialog(maLHP: maLHP),
    );

    if (!mounted || daThem != true) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã thêm sinh viên vào lớp.')));
  }

  void _moDanhSach(String maLHP) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DanhSachGhiDanhScreen(maLHP: maLHP)),
    );
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Không tải được lớp.\n${snapshot.error}',
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

          final danhSach = snapshot.data!.docs.toList()
            ..sort((a, b) => a.id.compareTo(b.id));

          if (danhSach.isEmpty) {
            return const Center(child: Text('Chưa có lớp học phần.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: danhSach.length,
            itemBuilder: (context, index) {
              final doc = danhSach[index];
              final data = doc.data();
              final tenMon = data['tenMon'] as String? ?? '';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${doc.id} — $tenMon',
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
                            onPressed: () => _moDanhSach(doc.id),
                            child: const Text('Xem danh sách'),
                          ),
                          FilledButton(
                            onPressed: () => _moGhiDanh(doc.id),
                            child: const Text('Thêm sinh viên'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _moTaoLich(maLHP: doc.id, tenMon: tenMon),
                            icon: const Icon(Icons.calendar_month),
                            label: const Text('Tạo lịch học'),
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
  final _service = QuanLyHocPhanService();

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

    var thanhCong = false;

    try {
      await _service.ghiDanh(maLHP: widget.maLHP, maSV: _maController.text);

      thanhCong = true;
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

    if (!mounted || !thanhCong) return;

    Navigator.pop(context, true);
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
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  void _taiDuLieu() {
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
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Không tải được danh sách.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => setState(_taiDuLieu),
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

          final danhSach = snapshot.data!.docs;

          if (danhSach.isEmpty) {
            return const Center(child: Text('Chưa có sinh viên trong lớp.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: danhSach.length,
            itemBuilder: (context, index) {
              final data = danhSach[index].data();

              return Card(
                child: ListTile(
                  title: Text('${data['maSV']} — ${data['hoTen']}'),
                  subtitle: Text('Điểm: ${data['diem'] ?? 'Chưa có điểm'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
