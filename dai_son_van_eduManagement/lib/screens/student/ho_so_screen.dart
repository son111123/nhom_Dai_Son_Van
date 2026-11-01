import 'package:flutter/material.dart';

import '../../models/sinh_vien.dart';
import '../../services/sinh_vien_service.dart';

class HoSoScreen extends StatefulWidget {
  final String maSV;

  const HoSoScreen({super.key, required this.maSV});

  @override
  State<HoSoScreen> createState() => _HoSoScreenState();
}

class _HoSoScreenState extends State<HoSoScreen> {
  late final Stream<SinhVien?> _hoSoStream;

  @override
  void initState() {
    super.initState();

    _hoSoStream = SinhVienService().layChiTiet(widget.maSV);
  }

  Widget _dong(String nhan, String giaTri) {
    return ListTile(
      title: Text(nhan),
      subtitle: Text(
        giaTri,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: StreamBuilder<SinhVien?>(
        stream: _hoSoStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Không đọc được hồ sơ.\nKiểm tra mạng và quyền truy cập.',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sv = snapshot.data;

          if (sv == null) {
            return const Center(
              child: Text(
                'Chưa có hồ sơ sinh viên.\nVui lòng liên hệ quản trị viên.',
                textAlign: TextAlign.center,
              ),
            );
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
