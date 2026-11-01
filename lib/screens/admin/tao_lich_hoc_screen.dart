import 'package:flutter/material.dart';

import '../../services/lich_hoc_service.dart';

class TaoLichHocScreen extends StatefulWidget {
  final String maLHP;
  final String tenMon;

  const TaoLichHocScreen({
    super.key,
    required this.maLHP,
    required this.tenMon,
  });

  @override
  State<TaoLichHocScreen> createState() => _TaoLichHocScreenState();
}

class _TaoLichHocScreenState extends State<TaoLichHocScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phongController = TextEditingController();
  final _service = LichHocService();

  DateTime _ngayHoc = DateUtils.dateOnly(DateTime.now());
  TimeOfDay _gioBatDau = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _gioKetThuc = const TimeOfDay(hour: 9, minute: 0);

  bool _dangLuu = false;
  String? _loi;

  @override
  void dispose() {
    _phongController.dispose();
    super.dispose();
  }

  String _haiSo(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _ngayHienThi(DateTime ngay) {
    return '${_haiSo(ngay.day)}/${_haiSo(ngay.month)}/${ngay.year}';
  }

  String _gioHienThi(TimeOfDay gio) {
    return '${_haiSo(gio.hour)}:${_haiSo(gio.minute)}';
  }

  DateTime _ghepNgayGio(TimeOfDay gio) {
    return DateTime(
      _ngayHoc.year,
      _ngayHoc.month,
      _ngayHoc.day,
      gio.hour,
      gio.minute,
    );
  }

  Future<void> _chonNgay() async {
    final namHienTai = DateTime.now().year;

    final ngay = await showDatePicker(
      context: context,
      initialDate: _ngayHoc,
      firstDate: DateTime(namHienTai - 5),
      lastDate: DateTime(namHienTai + 5, 12, 31),
      helpText: 'Chọn ngày học',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (!mounted || ngay == null) return;

    setState(() {
      _ngayHoc = DateUtils.dateOnly(ngay);
      _loi = null;
    });
  }

  Future<void> _chonGio({required bool laGioBatDau}) async {
    final gio = await showTimePicker(
      context: context,
      initialTime: laGioBatDau ? _gioBatDau : _gioKetThuc,
      helpText: laGioBatDau ? 'Chọn giờ bắt đầu' : 'Chọn giờ kết thúc',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (!mounted || gio == null) return;

    setState(() {
      if (laGioBatDau) {
        _gioBatDau = gio;
      } else {
        _gioKetThuc = gio;
      }

      _loi = null;
    });
  }

  Future<void> _luu() async {
    if (_dangLuu) return;
    if (!_formKey.currentState!.validate()) return;

    final batDau = _ghepNgayGio(_gioBatDau);
    final ketThuc = _ghepNgayGio(_gioKetThuc);

    if (!ketThuc.isAfter(batDau)) {
      setState(() {
        _loi = 'Giờ kết thúc phải sau giờ bắt đầu trong cùng ngày.';
      });
      return;
    }

    setState(() {
      _dangLuu = true;
      _loi = null;
    });

    var thanhCong = false;

    try {
      await _service.taoLichHoc(
        maLHP: widget.maLHP,
        phongHoc: _phongController.text,
        batDau: batDau,
        ketThuc: ketThuc,
      );

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

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dangLuu,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tạo lịch học')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tenMon,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Lớp học phần: ${widget.maLHP}'),
                      const SizedBox(height: 8),
                      const Text(
                        'Giảng viên được lấy theo phân công '
                        'của lớp học phần.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _dangLuu ? null : _chonNgay,
                icon: const Icon(Icons.calendar_month),
                label: Text('Ngày học: ${_ngayHienThi(_ngayHoc)}'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _dangLuu ? null : () => _chonGio(laGioBatDau: true),
                icon: const Icon(Icons.access_time),
                label: Text('Bắt đầu: ${_gioHienThi(_gioBatDau)}'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _dangLuu ? null : () => _chonGio(laGioBatDau: false),
                icon: const Icon(Icons.access_time_filled),
                label: Text('Kết thúc: ${_gioHienThi(_gioKetThuc)}'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phongController,
                enabled: !_dangLuu,
                maxLength: 50,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Phòng học',
                  hintText: 'Ví dụ: A201',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final phong = (value ?? '').trim();

                  if (phong.isEmpty) {
                    return 'Vui lòng nhập phòng học';
                  }

                  if (phong.toUpperCase().length > 50) {
                    return 'Phòng học không được quá 50 ký tự';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Mỗi lần lưu tạo một buổi học cụ thể. '
                'Lịch chưa tự lặp lại theo tuần.',
              ),
              if (_loi != null) ...[
                const SizedBox(height: 16),
                Text(
                  _loi!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _dangLuu ? null : _luu,
                icon: const Icon(Icons.save_outlined),
                label: Text(_dangLuu ? 'Đang lưu...' : 'Lưu lịch học'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
