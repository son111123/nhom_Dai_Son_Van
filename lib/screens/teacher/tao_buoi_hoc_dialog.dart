import 'package:flutter/material.dart';

import '../../services/diem_danh_service.dart';

class TaoBuoiHocDialog extends StatefulWidget {
  final String maLHP;

  const TaoBuoiHocDialog({super.key, required this.maLHP});

  @override
  State<TaoBuoiHocDialog> createState() => _TaoBuoiHocDialogState();
}

class _TaoBuoiHocDialogState extends State<TaoBuoiHocDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tietBatDauController = TextEditingController(text: '1');
  final _soTietController = TextEditingController(text: '3');
  final _service = DiemDanhService();

  DateTime _ngayHoc = DateUtils.dateOnly(DateTime.now());
  bool _dangLuu = false;
  String? _loi;

  @override
  void dispose() {
    _tietBatDauController.dispose();
    _soTietController.dispose();
    super.dispose();
  }

  String _dinhDangNgay(DateTime ngay) {
    final ngayText = ngay.day.toString().padLeft(2, '0');
    final thangText = ngay.month.toString().padLeft(2, '0');

    return '$ngayText/$thangText/${ngay.year}';
  }

  String? _kiemTraSoNguyenDuong(String? value) {
    final so = int.tryParse((value ?? '').trim());

    if (so == null || so < 1) {
      return 'Nhập số nguyên lớn hơn hoặc bằng 1';
    }

    return null;
  }

  Future<void> _chonNgay() async {
    final namHienTai = DateTime.now().year;

    final ngayDuocChon = await showDatePicker(
      context: context,
      initialDate: _ngayHoc,
      firstDate: DateTime(namHienTai - 5),
      lastDate: DateTime(namHienTai + 5, 12, 31),
      helpText: 'Chọn ngày học',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (!mounted || ngayDuocChon == null) return;

    setState(() {
      _ngayHoc = DateUtils.dateOnly(ngayDuocChon);
      _loi = null;
    });
  }

  Future<void> _taoBuoiHoc() async {
    if (_dangLuu) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _dangLuu = true;
      _loi = null;
    });

    try {
      final maBuoi = await _service.taoBuoiHoc(
        maLHP: widget.maLHP,
        ngayHoc: _ngayHoc,
        tietBatDau: int.parse(_tietBatDauController.text.trim()),
        soTiet: int.parse(_soTietController.text.trim()),
      );

      if (!mounted) return;

      Navigator.of(context).pop(maBuoi);
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
        title: const Text('Tạo buổi học'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Lớp học phần: ${widget.maLHP}'),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _dangLuu ? null : _chonNgay,
                  icon: const Icon(Icons.calendar_month),
                  label: Text('Ngày học: ${_dinhDangNgay(_ngayHoc)}'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tietBatDauController,
                  enabled: !_dangLuu,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tiết bắt đầu',
                    border: OutlineInputBorder(),
                  ),
                  validator: _kiemTraSoNguyenDuong,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _soTietController,
                  enabled: !_dangLuu,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tiết',
                    border: OutlineInputBorder(),
                  ),
                  validator: _kiemTraSoNguyenDuong,
                ),
                if (_loi != null) ...[
                  const SizedBox(height: 16),
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
            onPressed: _dangLuu ? null : () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: _dangLuu ? null : _taoBuoiHoc,
            child: Text(_dangLuu ? 'Đang tạo...' : 'Tạo'),
          ),
        ],
      ),
    );
  }
}
