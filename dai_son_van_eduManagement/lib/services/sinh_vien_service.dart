import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sinh_vien.dart';

class SinhVienService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<SinhVien>> layDanhSach() {
    return _db.collection('sinhVien').snapshots().map((snapshot) {
      final danhSach = snapshot.docs.map((doc) {
        return SinhVien.fromMap(doc.id, doc.data());
      }).toList();

      danhSach.sort((a, b) => a.maSV.compareTo(b.maSV));

      return danhSach;
    });
  }

  Stream<SinhVien?> layChiTiet(String maSV) {
    return _db.collection('sinhVien').doc(maSV).snapshots().map((doc) {
      final data = doc.data();

      if (data == null) return null;

      return SinhVien.fromMap(doc.id, data);
    });
  }

  Future<void> luu(SinhVien sv, {required bool laThemMoi}) async {
    final document = _db.collection('sinhVien').doc(sv.maSV);

    await _db.runTransaction((transaction) async {
      final hoSo = await transaction.get(document);
      final lop = await transaction.get(_db.collection('lop').doc(sv.maLop));

      if (!lop.exists) {
        throw Exception('Lớp đã chọn không tồn tại.');
      }

      if (laThemMoi && hoSo.exists) {
        throw Exception('Mã sinh viên đã tồn tại.');
      }

      if (!laThemMoi && !hoSo.exists) {
        throw Exception('Hồ sơ sinh viên đã bị xóa.');
      }

      transaction.set(document, sv.toMap(), SetOptions(merge: true));
    });
  }

  Future<void> xoa(String maSV) async {
    final document = _db.collection('sinhVien').doc(maSV);
    final snapshot = await document.get();

    if (!snapshot.exists) {
      throw Exception('Hồ sơ không còn tồn tại.');
    }

    if (snapshot.data()?['daGhiDanh'] == true) {
      throw Exception('Sinh viên đã được ghi danh, không thể xóa.');
    }

    // Kiem tra them cac ban ghi cu tao thu cong.
    final ketQua = await _db
        .collection('ketQua')
        .where('maSV', isEqualTo: maSV)
        .limit(1)
        .get();

    if (ketQua.docs.isNotEmpty) {
      throw Exception('Sinh viên đã có kết quả học tập, không thể xóa.');
    }

    await document.delete();
  }
}
