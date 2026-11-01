import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bao_cao_tong_quan.dart';

class BaoCaoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _kiemTraQuyenAdmin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    final taiKhoan = await _db
        .collection('users')
        .doc(user.uid)
        .get(const GetOptions(source: Source.server));

    if (taiKhoan.data()?['role'] != 'admin') {
      throw Exception('Chỉ quản trị viên được xem báo cáo tổng quan.');
    }
  }

  Future<BaoCaoTongQuan> layTongQuan() async {
    await _kiemTraQuyenAdmin();

    // Đọc từ máy chủ để tránh dùng dữ liệu lưu đệm cũ.
    // Nếu một truy vấn thất bại, báo cáo sẽ báo lỗi.
    final duLieu = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
      _db.collection('sinhVien').get(const GetOptions(source: Source.server)),
      _db.collection('lop').get(const GetOptions(source: Source.server)),
      _db.collection('lopHocPhan').get(const GetOptions(source: Source.server)),
    ]);

    final sinhVienDocs = duLieu[0].docs;
    final lopDocs = duLieu[1].docs;
    final lopHocPhanDocs = duLieu[2].docs;

    final soLuongTheoLop = <String, int>{};

    // Khởi tạo cả các lớp chưa có sinh viên.
    for (final lop in lopDocs) {
      soLuongTheoLop[lop.id] = 0;
    }

    var chuaXacDinhLop = 0;

    for (final sinhVien in sinhVienDocs) {
      final maLop = sinhVien.data()['maLop'];

      if (maLop is String && soLuongTheoLop.containsKey(maLop)) {
        soLuongTheoLop[maLop] = soLuongTheoLop[maLop]! + 1;
      } else {
        // Không bỏ qua hồ sơ thiếu lớp hoặc có mã lớp không tồn tại.
        chuaXacDinhLop++;
      }
    }

    final thongKeTheoLop = lopDocs.map((lop) {
      final tenLop = lop.data()['tenLop'];

      return ThongKeSinhVienTheoLop(
        maLop: lop.id,
        tenLop: tenLop is String && tenLop.trim().isNotEmpty
            ? tenLop.trim()
            : lop.id,
        soSinhVien: soLuongTheoLop[lop.id]!,
      );
    }).toList();

    thongKeTheoLop.sort((a, b) => a.maLop.compareTo(b.maLop));

    final baoCao = BaoCaoTongQuan(
      tongSinhVien: sinhVienDocs.length,
      tongLopHocPhan: lopHocPhanDocs.length,
      soSinhVienChuaXacDinhLop: chuaXacDinhLop,
      sinhVienTheoLop: thongKeTheoLop,
      capNhatLuc: DateTime.now(),
    );

    if (!baoCao.soLieuKhop) {
      throw StateError('Tổng sinh viên không khớp với thống kê theo lớp.');
    }

    return baoCao;
  }
}
