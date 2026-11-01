import 'package:flutter/material.dart';

import '../../models/buoi_hoc.dart';
import '../../services/diem_danh_service.dart';
import 'diem_danh_screen.dart';
import 'tao_buoi_hoc_dialog.dart';
import 'thong_ke_chuyen_can_screen.dart';

class BuoiHocScreen extends StatefulWidget {
  final String maLHP;
  final String tenMon;

  const BuoiHocScreen({super.key, required this.maLHP, required this.tenMon});

  @override
  State<BuoiHocScreen> createState() => _BuoiHocScreenState();
}

class _BuoiHocScreenState extends State<BuoiHocScreen> {
  final DiemDanhService _service = DiemDanhService();

  late Stream<List<BuoiHoc>> _buoiHocStream;

  DateTimeRange? _khoangNgay;

  @override
  void initState() {
    super.initState();
    _buoiHocStream = _service.layDanhSachBuoi(widget.maLHP);
  }

  void _thuLai() {
    setState(() {
      _buoiHocStream = _service.layDanhSachBuoi(widget.maLHP);
    });
  }

  String _dinhDangNgay(DateTime ngay) {
    final ngayText = ngay.day.toString().padLeft(2, '0');
    final thangText = ngay.month.toString().padLeft(2, '0');

    return '$ngayText/$thangText/${ngay.year}';
  }

  Future<void> _moTaoBuoiHoc() async {
    final maBuoi = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TaoBuoiHocDialog(maLHP: widget.maLHP),
    );

    if (!mounted || maBuoi == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo buổi học và danh sách điểm danh.')),
    );
  }

  Future<void> _chonKhoangNgay() async {
    final namHienTai = DateTime.now().year;

    final ketQua = await showDateRangePicker(
      context: context,
      initialDateRange: _khoangNgay,
      firstDate: DateTime(namHienTai - 5),
      lastDate: DateTime(namHienTai + 5, 12, 31),
      helpText: 'Chọn khoảng ngày xem lịch sử',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      saveText: 'Áp dụng',
    );

    if (!mounted || ketQua == null) return;

    setState(() {
      _khoangNgay = ketQua;
    });
  }

  void _xoaBoLoc() {
    setState(() {
      _khoangNgay = null;
    });
  }

  void _moDiemDanh(BuoiHoc buoi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiemDanhScreen(
          maLHP: widget.maLHP,
          maBuoi: buoi.maBuoi,
          daChot: buoi.daChot,
        ),
      ),
    );
  }

  void _moThongKe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ThongKeChuyenCanScreen(maLHP: widget.maLHP, tenMon: widget.tenMon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý điểm danh'),
        actions: [
          IconButton(
            tooltip: 'Lọc lịch sử theo ngày',
            icon: const Icon(Icons.date_range),
            onPressed: _chonKhoangNgay,
          ),
          IconButton(
            tooltip: 'Thống kê chuyên cần',
            icon: const Icon(Icons.bar_chart),
            onPressed: _moThongKe,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _moTaoBuoiHoc,
        icon: const Icon(Icons.add),
        label: const Text('Tạo buổi học'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${widget.maLHP} — ${widget.tenMon}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (_khoangNgay != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                children: [
                  InputChip(
                    label: Text(
                      '${_dinhDangNgay(_khoangNgay!.start)}'
                      ' – ${_dinhDangNgay(_khoangNgay!.end)}',
                    ),
                    onPressed: _chonKhoangNgay,
                    onDeleted: _xoaBoLoc,
                    deleteButtonTooltipMessage: 'Xóa bộ lọc ngày',
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<BuoiHoc>>(
              stream: _buoiHocStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Không tải được danh sách buổi học.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
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

                final khoangNgay = _khoangNgay;

                final danhSach = snapshot.data!.where((buoi) {
                  if (khoangNgay == null) return true;

                  final ngayHoc = DateUtils.dateOnly(buoi.ngayHoc);
                  final tuNgay = DateUtils.dateOnly(khoangNgay.start);
                  final denNgay = DateUtils.dateOnly(khoangNgay.end);

                  return !ngayHoc.isBefore(tuNgay) && !ngayHoc.isAfter(denNgay);
                }).toList();

                if (danhSach.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        khoangNgay == null
                            ? 'Lớp học phần chưa có buổi điểm danh.'
                            : 'Không có buổi học trong khoảng ngày đã chọn.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: danhSach.length,
                  itemBuilder: (context, index) {
                    final buoi = danhSach[index];

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          buoi.daChot
                              ? Icons.task_alt
                              : Icons.edit_calendar_outlined,
                          color: buoi.daChot ? Colors.green : Colors.orange,
                        ),
                        title: Text(_dinhDangNgay(buoi.ngayHoc)),
                        subtitle: Text(
                          'Tiết ${buoi.tietBatDau}'
                          '–${buoi.tietKetThuc}'
                          ' · ${buoi.trangThai.nhan}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _moDiemDanh(buoi),
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
