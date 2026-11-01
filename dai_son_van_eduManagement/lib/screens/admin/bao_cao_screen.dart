import 'package:flutter/material.dart';

import '../../models/bao_cao_tong_quan.dart';
import '../../services/bao_cao_service.dart';

class BaoCaoScreen extends StatefulWidget {
  const BaoCaoScreen({super.key});

  @override
  State<BaoCaoScreen> createState() => _BaoCaoScreenState();
}

class _BaoCaoScreenState extends State<BaoCaoScreen> {
  final _service = BaoCaoService();

  late Future<BaoCaoTongQuan> _baoCaoFuture;

  @override
  void initState() {
    super.initState();
    _baoCaoFuture = _service.layTongQuan();
  }

  void _taiLai() {
    setState(() {
      _baoCaoFuture = _service.layTongQuan();
    });
  }

  String _haiSo(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _thoiGianHienThi(DateTime value) {
    final ngay = value.toLocal();

    return '${_haiSo(ngay.day)}/${_haiSo(ngay.month)}/${ngay.year}'
        ' ${_haiSo(ngay.hour)}:${_haiSo(ngay.minute)}';
  }

  Widget _theSoLieu({
    required String nhan,
    required int giaTri,
    required IconData icon,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
            const SizedBox(height: 12),
            Text('$giaTri', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(nhan),
          ],
        ),
      ),
    );
  }

  Widget _noiDung(BaoCaoTongQuan baoCao) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tổng quan dữ liệu',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text('Cập nhật: ${_thoiGianHienThi(baoCao.capNhatLuc)}'),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final soCot = constraints.maxWidth >= 700
                ? 3
                : (constraints.maxWidth >= 360 ? 2 : 1);

            final chieuRong = (constraints.maxWidth - (soCot - 1) * 12) / soCot;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: chieuRong,
                  child: _theSoLieu(
                    nhan: 'Tổng sinh viên',
                    giaTri: baoCao.tongSinhVien,
                    icon: Icons.people_outline,
                  ),
                ),
                SizedBox(
                  width: chieuRong,
                  child: _theSoLieu(
                    nhan: 'Lớp hành chính',
                    giaTri: baoCao.tongLopHanhChinh,
                    icon: Icons.class_outlined,
                  ),
                ),
                SizedBox(
                  width: chieuRong,
                  child: _theSoLieu(
                    nhan: 'Lớp học phần',
                    giaTri: baoCao.tongLopHocPhan,
                    icon: Icons.school_outlined,
                  ),
                ),
              ],
            );
          },
        ),
        if (baoCao.soSinhVienChuaXacDinhLop > 0) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Có ${baoCao.soSinhVienChuaXacDinhLop} sinh viên '
                'chưa xác định được lớp hành chính.\n'
                'Hãy kiểm tra hồ sơ thiếu mã lớp hoặc có mã lớp '
                'không tồn tại.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Sinh viên theo lớp hành chính',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Mỗi hồ sơ sinh viên được tính vào một lớp hành chính. '
          'Số liệu này không phải số lượt ghi danh lớp học phần.',
        ),
        const SizedBox(height: 12),
        if (baoCao.sinhVienTheoLop.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('Chưa có lớp hành chính.', textAlign: TextAlign.center),
          )
        else
          for (final lop in baoCao.sinhVienTheoLop)
            Card(
              child: ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(lop.tenLop),
                subtitle: Text('Mã lớp: ${lop.maLop}'),
                trailing: Text(
                  '${lop.soSinhVien} SV',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        const SizedBox(height: 12),
        Text(
          'Đã xác định lớp: ${baoCao.soSinhVienDaXacDinhLop}'
          ' / ${baoCao.tongSinhVien} sinh viên',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê và báo cáo'),
        actions: [
          IconButton(
            tooltip: 'Tải lại số liệu',
            onPressed: _taiLai,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<BaoCaoTongQuan>(
        future: _baoCaoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Không tải được báo cáo.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _taiLai,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final baoCao = snapshot.data;

          if (baoCao == null) {
            return const Center(child: Text('Chưa có dữ liệu báo cáo.'));
          }

          return _noiDung(baoCao);
        },
      ),
    );
  }
}
