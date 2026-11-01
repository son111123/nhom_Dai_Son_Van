import 'package:flutter/material.dart';

import '../../models/bao_cao_vang_hoc.dart';
import '../../services/bao_cao_service.dart';

class BaoCaoVangHocScreen extends StatefulWidget {
  const BaoCaoVangHocScreen({super.key});

  @override
  State<BaoCaoVangHocScreen> createState() => _BaoCaoVangHocScreenState();
}

class _BaoCaoVangHocScreenState extends State<BaoCaoVangHocScreen> {
  final _service = BaoCaoService();

  late DateTimeRange _khoangNgay;
  Future<BaoCaoVangHoc>? _baoCaoFuture;

  @override
  void initState() {
    super.initState();

    final homNay = DateUtils.dateOnly(DateTime.now());

    _khoangNgay = DateTimeRange(
      start: DateTime(homNay.year, homNay.month, 1),
      end: homNay,
    );
  }

  String _dinhDangNgay(DateTime ngay) {
    final ngayText = ngay.day.toString().padLeft(2, '0');
    final thangText = ngay.month.toString().padLeft(2, '0');

    return '$ngayText/$thangText/${ngay.year}';
  }

  Future<void> _chonKhoangNgay() async {
    final namHienTai = DateTime.now().year;

    final ketQua = await showDateRangePicker(
      context: context,
      initialDateRange: _khoangNgay,
      firstDate: DateTime(namHienTai - 5),
      lastDate: DateTime(namHienTai + 5, 12, 31),
      helpText: 'Chọn khoảng ngày báo cáo',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      saveText: 'Áp dụng',
    );

    if (!mounted || ketQua == null) return;

    setState(() {
      _khoangNgay = ketQua;
      _baoCaoFuture = null;
    });
  }

  void _taiBaoCao() {
    setState(() {
      _baoCaoFuture = _service.layBaoCaoVangHoc(
        tuNgay: _khoangNgay.start,
        denNgay: _khoangNgay.end,
      );
    });
  }

  Widget _noiDungBaoCao(BaoCaoVangHoc baoCao) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng hợp vắng học',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_dinhDangNgay(baoCao.tuNgay)}'
                  ' – ${_dinhDangNgay(baoCao.denNgay)}',
                ),
                const SizedBox(height: 12),
                Text('Buổi đã chốt: ${baoCao.soBuoiDaChot}'),
                Text('Sinh viên vắng: ${baoCao.soSinhVienVang}'),
                Text('Tổng lượt vắng: ${baoCao.tongLuotVang}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Chỉ tính trạng thái Vắng mặt trong các buổi đã chốt. '
          'Một sinh viên vắng nhiều buổi chỉ được đếm một lần '
          'ở mục “Sinh viên vắng”.',
        ),
        const SizedBox(height: 20),
        if (baoCao.soBuoiDaChot == 0)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Chưa có buổi điểm danh đã chốt '
              'trong khoảng ngày này.',
              textAlign: TextAlign.center,
            ),
          )
        else if (baoCao.danhSach.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Không có sinh viên vắng trong các buổi đã chốt.',
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          Text(
            'Danh sách sinh viên vắng',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Sắp xếp theo số lượt vắng giảm dần.'),
          const SizedBox(height: 8),
          for (final sv in baoCao.danhSach)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${sv.maSV} — ${sv.hoTen}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Số lượt vắng: ${sv.soLuotVang}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ngày vắng gần nhất: '
                      '${_dinhDangNgay(sv.ngayVangGanNhat)}',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo vắng học')),
      body: FutureBuilder<BaoCaoVangHoc>(
        future: _baoCaoFuture,
        builder: (context, snapshot) {
          final dangTai =
              _baoCaoFuture != null &&
              snapshot.connectionState != ConnectionState.done;

          Widget ketQua;

          if (_baoCaoFuture == null) {
            ketQua = const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chọn khoảng ngày rồi bấm “Xem báo cáo”.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (dangTai) {
            ketQua = const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            ketQua = Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Không tải được báo cáo vắng học.\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _taiBaoCao,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.data == null) {
            ketQua = const Center(child: Text('Chưa có dữ liệu báo cáo.'));
          } else {
            ketQua = _noiDungBaoCao(snapshot.data!);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: dangTai ? null : _chonKhoangNgay,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        '${_dinhDangNgay(_khoangNgay.start)}'
                        ' – ${_dinhDangNgay(_khoangNgay.end)}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: dangTai ? null : _taiBaoCao,
                      icon: const Icon(Icons.search),
                      label: Text(dangTai ? 'Đang tải...' : 'Xem báo cáo'),
                    ),
                  ],
                ),
              ),
              Expanded(child: ketQua),
            ],
          );
        },
      ),
    );
  }
}
