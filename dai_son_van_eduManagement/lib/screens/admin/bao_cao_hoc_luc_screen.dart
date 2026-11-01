import 'package:flutter/material.dart';

import '../../models/bao_cao_hoc_luc.dart';
import '../../services/bao_cao_service.dart';

class BaoCaoHocLucScreen extends StatefulWidget {
  const BaoCaoHocLucScreen({super.key});

  @override
  State<BaoCaoHocLucScreen> createState() => _BaoCaoHocLucScreenState();
}

class _BaoCaoHocLucScreenState extends State<BaoCaoHocLucScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namHocController = TextEditingController();
  final _service = BaoCaoService();

  int _hocKy = 1;
  Future<BaoCaoHocLuc>? _baoCaoFuture;

  @override
  void dispose() {
    _namHocController.dispose();
    super.dispose();
  }

  void _taiBaoCao() {
    if (!_formKey.currentState!.validate()) return;

    final namHoc = _namHocController.text.trim();

    setState(() {
      _baoCaoFuture = _service.layBaoCaoHocLuc(namHoc: namHoc, hocKy: _hocKy);
    });
  }

  String? _kiemTraNamHoc(String? value) {
    final nam = (value ?? '').trim();

    if (!RegExp(r'^[0-9]{4}-[0-9]{4}$').hasMatch(nam)) {
      return 'Nhập năm học theo dạng 2026-2027';
    }

    final cacNam = nam.split('-');

    if (int.parse(cacNam[1]) != int.parse(cacNam[0]) + 1) {
      return 'Hai năm phải liên tiếp';
    }

    return null;
  }

  Widget _dongThongKe({
    required String nhan,
    required int soLuong,
    required int tongSinhVien,
  }) {
    final tiLe = tongSinhVien == 0 ? 0.0 : soLuong / tongSinhVien;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  nhan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$soLuong sinh viên'
                  ' · ${(tiLe * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: tiLe,
              minHeight: 8,
              semanticsLabel: nhan,
              semanticsValue: '$soLuong sinh viên',
            ),
          ],
        ),
      ),
    );
  }

  Widget _noiDungBaoCao(BaoCaoHocLuc baoCao) {
    if (baoCao.tongSinhVien == 0) {
      return const Center(child: Text('Hệ thống chưa có hồ sơ sinh viên.'));
    }

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
                  'Học kỳ ${baoCao.hocKy} · ${baoCao.namHoc}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text('Tổng sinh viên: ${baoCao.tongSinhVien}'),
                Text('Đã xếp loại: ${baoCao.soDaXepLoai}'),
                Text('Chờ đủ điểm: ${baoCao.soChoDuDiem}'),
                Text('Chưa có điểm: ${baoCao.soChuaCoDiem}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tỷ lệ tính trên toàn bộ hồ sơ sinh viên hiện có. '
          'Xếp loại dùng điểm trung bình theo tín chỉ '
          'và quy ước của dự án.',
        ),
        const SizedBox(height: 12),
        for (final nhom in baoCao.soLuongTheoXepLoai.entries)
          _dongThongKe(
            nhan: nhom.key,
            soLuong: nhom.value,
            tongSinhVien: baoCao.tongSinhVien,
          ),
        _dongThongKe(
          nhan: 'Chờ đủ điểm',
          soLuong: baoCao.soChoDuDiem,
          tongSinhVien: baoCao.tongSinhVien,
        ),
        _dongThongKe(
          nhan: 'Chưa có điểm',
          soLuong: baoCao.soChuaCoDiem,
          tongSinhVien: baoCao.tongSinhVien,
        ),
        const SizedBox(height: 12),
        const Text(
          'Chờ đủ điểm: đã có điểm nhưng còn học phần chưa có điểm.\n\n'
          'Chưa có điểm: chưa có điểm ở học kỳ này, '
          'bao gồm sinh viên chưa ghi danh học phần nào.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê học lực')),
      body: FutureBuilder<BaoCaoHocLuc>(
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
                  'Chọn năm học và học kỳ rồi bấm “Xem báo cáo”.',
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
                      'Không tải được thống kê học lực.\n'
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
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _namHocController,
                        enabled: !dangTai,
                        decoration: const InputDecoration(
                          labelText: 'Năm học',
                          hintText: 'Ví dụ: 2026-2027',
                          border: OutlineInputBorder(),
                        ),
                        validator: _kiemTraNamHoc,
                        onChanged: (_) {
                          setState(() => _baoCaoFuture = null);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _hocKy,
                        decoration: const InputDecoration(
                          labelText: 'Học kỳ',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Học kỳ 1')),
                          DropdownMenuItem(value: 2, child: Text('Học kỳ 2')),
                          DropdownMenuItem(value: 3, child: Text('Học kỳ 3')),
                        ],
                        onChanged: dangTai
                            ? null
                            : (value) {
                                if (value == null) return;

                                setState(() {
                                  _hocKy = value;
                                  _baoCaoFuture = null;
                                });
                              },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: dangTai ? null : _taiBaoCao,
                          icon: const Icon(Icons.bar_chart),
                          label: Text(dangTai ? 'Đang tải...' : 'Xem báo cáo'),
                        ),
                      ),
                    ],
                  ),
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
