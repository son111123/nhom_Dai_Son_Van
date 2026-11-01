import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/lop_hanh_chinh.dart';
import '../../services/lop_service.dart';

class LopFormScreen extends StatefulWidget {
  const LopFormScreen({super.key});

  @override
  State<LopFormScreen> createState() => _LopFormScreenState();
}

class _LopFormScreenState extends State<LopFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _maLopController = TextEditingController();
  final _tenLopController = TextEditingController();
  final _khoaHocController = TextEditingController();

  final _lopService = LopService();

  bool _dangLuu = false;

  @override
  void dispose() {
    _maLopController.dispose();
    _tenLopController.dispose();
    _khoaHocController.dispose();
    super.dispose();
  }

  Future<void> _luuLop() async {
    if (_dangLuu) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _dangLuu = true);

    try {
      final lop = LopHanhChinh(
        maLop: _maLopController.text,
        tenLop: _tenLopController.text,
        khoaHoc: _khoaHocController.text,
      );

      await _lopService.themLop(lop);

      if (!mounted) return;

      // Tra ve true de man hinh danh sach hien thong bao.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      String thongBao;

      if (e is FirebaseException) {
        thongBao = e.code == 'permission-denied'
            ? 'Bạn không có quyền tạo lớp. Kiểm tra role và Firestore Rules.'
            : 'Không lưu được lớp. Mã lỗi: ${e.code}';
      } else {
        thongBao = e.toString().replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(thongBao)));
    } finally {
      if (mounted) {
        setState(() => _dangLuu = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm lớp hành chính')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _maLopController,
              enabled: !_dangLuu,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Mã lớp',
                hintText: 'Ví dụ: CNTT01',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final ma = value?.trim().toUpperCase() ?? '';

                if (ma.isEmpty) {
                  return 'Vui lòng nhập mã lớp';
                }

                if (!RegExp(r'^[A-Z0-9_-]{1,30}$').hasMatch(ma)) {
                  return 'Nhập 1–30 chữ không dấu, số, dấu - hoặc _';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _tenLopController,
              enabled: !_dangLuu,
              decoration: const InputDecoration(
                labelText: 'Tên lớp',
                hintText: 'Ví dụ: Công nghệ thông tin 01',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên lớp';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _khoaHocController,
              enabled: !_dangLuu,
              decoration: const InputDecoration(
                labelText: 'Khóa học',
                hintText: 'Ví dụ: K18',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập khóa học';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _dangLuu ? null : _luuLop,
              icon: const Icon(Icons.save_outlined),
              label: Text(_dangLuu ? 'Đang lưu...' : 'Lưu lớp'),
            ),
          ],
        ),
      ),
    );
  }
}
