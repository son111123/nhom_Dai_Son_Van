import 'package:flutter/material.dart';

import '../../models/thong_ke_chuyen_can.dart';
import '../../services/diem_danh_service.dart';

class ThongKeChuyenCanScreen extends StatefulWidget {
  final String maLHP;
  final String tenMon;

  const ThongKeChuyenCanScreen({
    super.key,
    required this.maLHP,
    required this.tenMon,
  });

  @override
  State<ThongKeChuyenCanScreen> createState() => _ThongKeChuyenCanScreenState();
}

class _ThongKeChuyenCanScreenState extends State<ThongKeChuyenCanScreen> {
  final _service = DiemDanhService();

  late Future<List<ThongKeChuyenCan>> _thongKeFuture;

  @override
  void initState() {
    super.initState();
    _thongKeFuture = _service.layThongKeChuyenCan(widget.maLHP);
  }

  void _taiLai() {
    setState(() {
      _thongKeFuture = _service.layThongKeChuyenCan(widget.maLHP);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê chuyên cần'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _taiLai,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.maLHP} — ${widget.tenMon}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chỉ tính các buổi đã chốt. '
                  'Đi muộn được tính là có tham dự.',
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ThongKeChuyenCan>>(
              future: _thongKeFuture,
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
                            'Không tải được thống kê.\n'
                            '${snapshot.error}',
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

                final danhSach = snapshot.data ?? [];

                if (danhSach.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Chưa có dữ liệu thống kê.\n'
                        'Hãy hoàn tất điểm danh và chốt một buổi học.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: danhSach.length,
                  itemBuilder: (context, index) {
                    final sv = danhSach[index];
                    final tyLe = sv.tyLeChuyenCan;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${sv.maSV} — ${sv.hoTen}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(label: Text('Có mặt: ${sv.coMat}')),
                                Chip(label: Text('Vắng: ${sv.vangMat}')),
                                Chip(label: Text('Đi muộn: ${sv.diMuon}')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Tổng số buổi được tính: ${sv.tongBuoi}'),
                            const SizedBox(height: 8),
                            Text(
                              'Chuyên cần: ${sv.tyLeHienThi}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (tyLe != null) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: tyLe / 100,
                                minHeight: 8,
                                semanticsLabel: 'Tỷ lệ chuyên cần',
                                semanticsValue: sv.tyLeHienThi,
                              ),
                            ],
                          ],
                        ),
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
