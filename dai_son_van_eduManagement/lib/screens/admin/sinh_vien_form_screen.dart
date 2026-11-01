import 'package:flutter/material.dart';

import '../../models/sinh_vien.dart';
import '../../models/lop_hanh_chinh.dart';
import '../../services/sinh_vien_service.dart';
import '../../services/lop_service.dart';

class SinhVienFormScreen extends StatefulWidget {
  final SinhVien? sinhVien;

  const SinhVienFormScreen({super.key, this.sinhVien});

  @override
  State<SinhVienFormScreen> createState() => _SinhVienFormScreenState();
}

class _SinhVienFormScreenState extends State<SinhVienFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SinhVienService();

  final _maController = TextEditingController();
  final _tenController = TextEditingController();
  final _ngaySinhController = TextEditingController();
  final _sdtController = TextEditingController();

  late final Future<List<LopHanhChinh>> _danhSachLop;

  String? _maLop;
  bool _dangLuu = false;

  bool get _laThemMoi => widget.sinhVien == null;

  @override
  void initState() {
    super.initState();

    _danhSachLop = LopService().layDanhSach().first;

    final sv = widget.sinhVien;

    if (sv != null) {
      _maController.text = sv.maSV;
      _tenController.text = sv.hoTen;
      _ngaySinhController.text = sv.ngaySinh;
      _sdtController.text = sv.soDienThoai;
      _maLop = sv.maLop;
    }
  }

  @override
  void dispose() {
    _maController.dispose();
    _tenController.dispose();
    _ngaySinhController.dispose();
    _sdtController.dispose();
    super.dispose();
  }

  Future<void> _chonNgaySinh() async {
    final homNay = DateUtils.dateOnly(DateTime.now());
    final ngayCu = DateTime.tryParse(_ngaySinhController.text);

    final ngayBanDau =
        ngayCu != null &&
            !ngayCu.isBefore(DateTime(1900)) &&
            !ngayCu.isAfter(homNay)
        ? ngayCu
        : DateTime(2005);

    final ngay = await showDatePicker(
      context: context,
      initialDate: ngayBanDau,
      firstDate: DateTime(1900),
      lastDate: homNay,
    );

    if (ngay == null || !mounted) return;

    _ngaySinhController.text =
        '${ngay.year}-'
        '${ngay.month.toString().padLeft(2, '0')}-'
        '${ngay.day.toString().padLeft(2, '0')}';
  }

  Future<void> _luu() async {
    if (_dangLuu) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _dangLuu = true);

    try {
      final sv = SinhVien(
        maSV: _maController.text.trim().toUpperCase(),
        hoTen: _tenController.text.trim(),
        ngaySinh: _ngaySinhController.text,
        soDienThoai: _sdtController.text.trim(),
        maLop: _maLop!,
      );

      await _service.luu(sv, laThemMoi: _laThemMoi);

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
      appBar: AppBar(
        title: Text(_laThemMoi ? 'Thêm sinh viên' : 'Sửa sinh viên'),
      ),
      body: FutureBuilder<List<LopHanhChinh>>(
        future: _danhSachLop,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Không tải được lớp. Kiểm tra mạng và quyền truy cập.',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final danhSachLop = snapshot.data!;

          if (danhSachLop.isEmpty) {
            return const Center(
              child: Text('Hãy tạo lớp hành chính trước khi thêm sinh viên.'),
            );
          }

          final lopConTonTai = danhSachLop.any((lop) => lop.maLop == _maLop);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _maController,
                  readOnly: !_laThemMoi,
                  enabled: !_dangLuu,
                  decoration: _trangTri('Mã sinh viên'),
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
                  decoration: _trangTri('Họ và tên'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ tên';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _ngaySinhController,
                  readOnly: true,
                  enabled: !_dangLuu,
                  onTap: _chonNgaySinh,
                  decoration: _trangTri('Ngày sinh')
                      .copyWith(suffixIcon: const Icon(Icons.calendar_month)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn ngày sinh';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _sdtController,
                  enabled: !_dangLuu,
                  keyboardType: TextInputType.phone,
                  decoration: _trangTri('Số điện thoại'),
                  validator: (value) {
                    final sdt = value?.trim() ?? '';

                    if (!RegExp(r'^0[0-9]{9}$').hasMatch(sdt)) {
                      return 'Nhập 10 chữ số bắt đầu bằng 0';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: lopConTonTai ? _maLop : null,
                  isExpanded: true,
                  decoration: _trangTri('Lớp hành chính'),
                  items: danhSachLop.map((lop) {
                    return DropdownMenuItem(
                      value: lop.maLop,
                      child: Text(
                        '${lop.maLop} — ${lop.tenLop}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _dangLuu
                      ? null
                      : (value) {
                          _maLop = value;
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn lớp';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _dangLuu ? null : _luu,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_dangLuu ? 'Đang lưu...' : 'Lưu sinh viên'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
