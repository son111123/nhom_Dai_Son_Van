import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/hoc_phan_service.dart';

class DanhSachDiemScreen extends StatefulWidget {
  final String maLHP;
  final String tenMon;

  const DanhSachDiemScreen({
    super.key,
    required this.maLHP,
    required this.tenMon,
  });

  @override
  State<DanhSachDiemScreen> createState() => _DanhSachDiemScreenState();
}

class _DanhSachDiemScreenState extends State<DanhSachDiemScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _diemStream;

  @override
  void initState() {
    super.initState();

    _diemStream = HocPhanService().layDanhSachDiem(widget.maLHP);
  }

  Future<void> _moNhapDiem(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final daLuu = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NhapDiemDialog(id: doc.id, data: doc.data()),
    );

    if (!mounted) return;

    if (daLuu == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã lưu điểm.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.maLHP} — ${widget.tenMon}')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _diemStream,
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

          final danhSach = snapshot.data!.docs;

          if (danhSach.isEmpty) {
            return const Center(child: Text('Lớp học phần chưa có sinh viên.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: danhSach.length,
            itemBuilder: (context, index) {
              final doc = danhSach[index];
              final data = doc.data();
              final diem = data['diem'];

              return Card(
                child: ListTile(
                  title: Text('${data['maSV']} — ${data['hoTen']}'),
                  subtitle: Text(diem == null ? 'Chưa có điểm' : 'Điểm: $diem'),
                  trailing: TextButton(
                    onPressed: () => _moNhapDiem(doc),
                    child: Text(diem == null ? 'Nhập điểm' : 'Sửa điểm'),
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

class NhapDiemDialog extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const NhapDiemDialog({super.key, required this.id, required this.data});

  @override
  State<NhapDiemDialog> createState() => _NhapDiemDialogState();
}

class _NhapDiemDialogState extends State<NhapDiemDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _diemController;

  bool _dangLuu = false;
  String? _loi;

  @override
  void initState() {
    super.initState();

    _diemController = TextEditingController(
      text: widget.data['diem']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _diemController.dispose();
    super.dispose();
  }

  double? _docDiem(String? value) {
    return double.tryParse((value ?? '').trim().replaceAll(',', '.'));
  }

  Future<void> _luu() async {
    if (_dangLuu) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _dangLuu = true;
      _loi = null;
    });

    try {
      await HocPhanService().luuDiem(
        id: widget.id,
        diemCu: widget.data['diem'] as num?,
        diemMoi: _docDiem(_diemController.text)!,
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
        title: Text(widget.data['diem'] == null ? 'Nhập điểm' : 'Sửa điểm'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.data['maSV']} — ${widget.data['hoTen']}'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _diemController,
                  enabled: !_dangLuu,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Điểm từ 0 đến 10',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final diem = _docDiem(value);

                    if (diem == null ||
                        !diem.isFinite ||
                        diem < 0 ||
                        diem > 10) {
                      return 'Nhập điểm hợp lệ từ 0 đến 10';
                    }

                    return null;
                  },
                ),
                if (_loi != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _loi!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _dangLuu ? null : () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: _dangLuu ? null : _luu,
            child: Text(_dangLuu ? 'Đang lưu...' : 'Lưu điểm'),
          ),
        ],
      ),
    );
  }
}
