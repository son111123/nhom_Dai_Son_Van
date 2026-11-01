import 'package:flutter/material.dart';

import '../../models/sinh_vien.dart';
import '../../services/sinh_vien_service.dart';

class SinhVienDetailScreen extends StatefulWidget {
  final String maSV;

  const SinhVienDetailScreen({super.key, required this.maSV});

  @override
  State<SinhVienDetailScreen> createState() => _SinhVienDetailScreenState();
}

class _SinhVienDetailScreenState extends State<SinhVienDetailScreen> {
  late final Stream<SinhVien?> _sinhVienStream;

  @override
  void initState() {
    super.initState();

    _sinhVienStream = SinhVienService().layChiTiet(widget.maSV);
  }

  Widget _dong(String nhan, String giaTri) {
    return ListTile(
      title: Text(nhan),
      subtitle: Text(giaTri, style: const TextStyle(fontSize: 17)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sinh viên')),
      body: StreamBuilder<SinhVien?>(
        stream: _sinhVienStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Không đọc được hồ sơ.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sv = snapshot.data;

          if (sv == null) {
            return const Center(child: Text('Hồ sơ không còn tồn tại.'));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.account_circle,
                size: 90,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              _dong('Mã sinh viên', sv.maSV),
              _dong('Họ và tên', sv.hoTen),
              _dong('Ngày sinh', sv.ngaySinh),
              _dong('Số điện thoại', sv.soDienThoai),
              _dong('Lớp hành chính', sv.maLop),
            ],
          );
        },
      ),
    );
  }
}
