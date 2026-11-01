import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bao_cao_tong_quan.dart';
import '../models/bao_cao_hoc_luc.dart';
import 'thong_ke_diem_service.dart';

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

  Future<BaoCaoHocLuc> layBaoCaoHocLuc({
    required String namHoc,
    required int hocKy,
  }) async {
    await _kiemTraQuyenAdmin();

    final nam = namHoc.trim();

    if (!RegExp(r'^[0-9]{4}-[0-9]{4}$').hasMatch(nam)) {
      throw Exception('Năm học phải có dạng 2026-2027.');
    }

    final cacNam = nam.split('-');

    if (int.parse(cacNam[1]) != int.parse(cacNam[0]) + 1) {
      throw Exception('Hai năm trong năm học phải liên tiếp.');
    }

    if (![1, 2, 3].contains(hocKy)) {
      throw Exception('Học kỳ không hợp lệ.');
    }

    final duLieu = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
      _db.collection('sinhVien').get(const GetOptions(source: Source.server)),
      _db
          .collection('ketQua')
          .where('namHoc', isEqualTo: nam)
          .where('hocKy', isEqualTo: hocKy)
          .get(const GetOptions(source: Source.server)),
    ]);

    final sinhVienDocs = duLieu[0].docs;
    final ketQuaDocs = duLieu[1].docs;

    final maSinhVienHienCo = sinhVienDocs.map((doc) => doc.id).toSet();

    final ketQuaTheoSinhVien = <String, List<Map<String, dynamic>>>{};

    for (final doc in ketQuaDocs) {
      final data = doc.data();
      final maSV = data['maSV'];

      if (maSV is! String || !maSinhVienHienCo.contains(maSV)) {
        throw Exception(
          'Bản ghi kết quả ${doc.id} tham chiếu '
          'đến sinh viên không tồn tại hoặc thiếu mã sinh viên.',
        );
      }

      ketQuaTheoSinhVien
          .putIfAbsent(maSV, () => <Map<String, dynamic>>[])
          .add(data);
    }

    final soLuongTheoXepLoai = <String, int>{
      'Xuất sắc': 0,
      'Giỏi': 0,
      'Khá': 0,
      'Trung bình': 0,
      'Yếu': 0,
    };

    var soChuaCoDiem = 0;
    var soChoDuDiem = 0;

    for (final sinhVien in sinhVienDocs) {
      final danhSach =
          ketQuaTheoSinhVien[sinhVien.id] ?? <Map<String, dynamic>>[];

      final tongHop = ThongKeDiemService.tinh(danhSach);

      if (tongHop.diemTrungBinh == null) {
        soChuaCoDiem++;
        continue;
      }

      if (tongHop.laTamTinh) {
        soChoDuDiem++;
        continue;
      }

      final xepLoai = tongHop.xepLoai;

      if (!soLuongTheoXepLoai.containsKey(xepLoai)) {
        throw StateError('Chưa hỗ trợ nhóm học lực: $xepLoai');
      }

      soLuongTheoXepLoai[xepLoai] = soLuongTheoXepLoai[xepLoai]! + 1;
    }

    final baoCao = BaoCaoHocLuc(
      namHoc: nam,
      hocKy: hocKy,
      tongSinhVien: sinhVienDocs.length,
      soChuaCoDiem: soChuaCoDiem,
      soChoDuDiem: soChoDuDiem,
      soLuongTheoXepLoai: soLuongTheoXepLoai,
      capNhatLuc: DateTime.now(),
    );

    if (!baoCao.soLieuKhop) {
      throw StateError('Số liệu thống kê học lực không khớp.');
    }

    return baoCao;
  }
}
