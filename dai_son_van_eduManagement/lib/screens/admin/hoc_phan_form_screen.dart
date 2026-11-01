import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/quan_ly_hoc_phan_service.dart';

class HocPhanFormScreen extends StatefulWidget {
  const HocPhanFormScreen({super.key});

  @override
  State<HocPhanFormScreen> createState() => _HocPhanFormScreenState();
}

class _HocPhanFormScreenState extends State<HocPhanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = QuanLyHocPhanService();

  final _maController = TextEditingController();
  final _namController = TextEditingController();

  late final Future<List<QuerySnapshot<Map<String, dynamic>>>> _duLieu;

  String? _maMon;
  String? _giangVienUid;
  int _hocKy = 1;
  bool _dangLuu = false;

  @override
  void initState() {
    super.initState();

    _duLieu = Future.wait([_service.layMonHoc(), _service.layGiangVien()]);
  }

  @override
  void dispose() {
    _maController.dispose();
    _namController.dispose();
    super.dispose();
  }

  Future<void> _luu() async {
    if (_dangLuu) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _dangLuu = true);

    try {
      await _service.taoLop(
        maLHP: _maController.text,
        maMon: _maMon!,
        giangVienUid: _giangVienUid!,
        hocKy: _hocKy,
        namHoc: _namController.text,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _dangLuu = false);
      }
    }
  }

  InputDecoration _trangTri(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo lớp học phần')),
      body: FutureBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
        future: _duLieu,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Không tải được dữ liệu:\n${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final monHoc = snapshot.data![0].docs;
          final giangVien = snapshot.data![1].docs;

          if (monHoc.isEmpty || giangVien.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Cần có ít nhất một môn học và một tài khoản '
                  'users có role là teacher.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _maController,
                  enabled: !_dangLuu,
                  decoration: _trangTri('Mã lớp học phần, ví dụ JAVA02'),
                  validator: (value) {
                    final ma = value?.trim().toUpperCase() ?? '';

                    if (!RegExp(r'^[A-Z0-9-]{1,30}$').hasMatch(ma)) {
                      return 'Dùng 1–30 chữ không dấu, số hoặc dấu -';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: _trangTri('Môn học'),
                  items: monHoc.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(
                        '${doc.id} — ${doc.data()['tenMon']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _dangLuu ? null : (value) => _maMon = value,
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn môn học' : null,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: _trangTri('Giảng viên phụ trách'),
                  items: giangVien.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(
                        '${doc.data()['hoTen'] ?? 'Giảng viên'}'
                        ' — ${doc.id}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _dangLuu ? null : (value) => _giangVienUid = value,
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn giảng viên' : null,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  initialValue: _hocKy,
                  decoration: _trangTri('Học kỳ'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Học kỳ 1')),
                    DropdownMenuItem(value: 2, child: Text('Học kỳ 2')),
                    DropdownMenuItem(value: 3, child: Text('Học kỳ 3')),
                  ],
                  onChanged: _dangLuu
                      ? null
                      : (value) {
                          if (value != null) _hocKy = value;
                        },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _namController,
                  enabled: !_dangLuu,
                  decoration: _trangTri('Năm học, ví dụ 2026-2027'),
                  validator: (value) {
                    final nam = value?.trim() ?? '';

                    if (!RegExp(r'^[0-9]{4}-[0-9]{4}$').hasMatch(nam)) {
                      return 'Nhập theo dạng 2026-2027';
                    }

                    final phan = nam.split('-');

                    if (int.parse(phan[1]) != int.parse(phan[0]) + 1) {
                      return 'Hai năm phải liên tiếp';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _dangLuu ? null : _luu,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_dangLuu ? 'Đang lưu...' : 'Tạo lớp học phần'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
