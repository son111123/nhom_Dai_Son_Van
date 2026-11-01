import 'package:flutter/material.dart';

import '../../models/mon_hoc.dart';
import '../../services/mon_hoc_service.dart';

class MonHocFormScreen extends StatefulWidget {
  final MonHoc? monHoc;

  const MonHocFormScreen({super.key, this.monHoc});

  @override
  State<MonHocFormScreen> createState() => _MonHocFormScreenState();
}

class _MonHocFormScreenState extends State<MonHocFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MonHocService();

  late final TextEditingController _maController;
  late final TextEditingController _tenController;
  late final TextEditingController _tinChiController;

  bool _dangLuu = false;

  bool get _dangSua => widget.monHoc != null;

  @override
  void initState() {
    super.initState();

    final mon = widget.monHoc;

    _maController = TextEditingController(text: mon?.maMon ?? '');
    _tenController = TextEditingController(text: mon?.tenMon ?? '');
    _tinChiController = TextEditingController(
      text: mon?.soTinChi.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _maController.dispose();
    _tenController.dispose();
    _tinChiController.dispose();
    super.dispose();
  }

  Future<void> _luu() async {
    if (_dangLuu) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _dangLuu = true);

    var thanhCong = false;

    try {
      final mon = MonHoc(
        maMon: _maController.text.trim().toUpperCase(),
        tenMon: _tenController.text.trim(),
        soTinChi: int.parse(_tinChiController.text.trim()),
      );

      final banCu = widget.monHoc;

      if (banCu == null) {
        await _service.themMonHoc(mon);
      } else {
        await _service.suaMonHoc(banCu: banCu, monMoi: mon);
      }

      thanhCong = true;
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

    if (!mounted || !thanhCong) return;

    Navigator.pop(context, true);
  }

  InputDecoration _trangTri(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dangLuu,
      child: Scaffold(
        appBar: AppBar(title: Text(_dangSua ? 'Sửa môn học' : 'Thêm môn học')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_dangSua) ...[
                const Text(
                  'Chỉ sửa được môn chưa phân cho lớp học phần. '
                  'Mã môn học được giữ nguyên.',
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _maController,
                enabled: !_dangLuu && !_dangSua,
                textCapitalization: TextCapitalization.characters,
                decoration: _trangTri('Mã môn học', 'Ví dụ: MH001'),
                validator: (value) {
                  final ma = value?.trim().toUpperCase() ?? '';

                  if (!RegExp(r'^[A-Z0-9_-]{1,30}$').hasMatch(ma)) {
                    return 'Nhập 1–30 chữ không dấu, số, dấu - hoặc _';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tenController,
                enabled: !_dangLuu,
                decoration: _trangTri('Tên môn học', 'Ví dụ: Lập trình Java'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên môn học';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tinChiController,
                enabled: !_dangLuu,
                keyboardType: TextInputType.number,
                decoration: _trangTri('Số tín chỉ', 'Ví dụ: 3'),
                validator: (value) {
                  final tinChi = int.tryParse(value?.trim() ?? '');

                  if (tinChi == null || tinChi <= 0) {
                    return 'Số tín chỉ phải là số nguyên dương';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _dangLuu ? null : _luu,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  _dangLuu
                      ? 'Đang lưu...'
                      : (_dangSua ? 'Lưu thay đổi' : 'Thêm môn học'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
