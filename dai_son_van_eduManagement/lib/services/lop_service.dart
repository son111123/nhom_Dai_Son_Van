import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lop_hanh_chinh.dart';

class LopService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Danh sach tu cap nhat khi Firestore thay doi.
  Stream<List<LopHanhChinh>> layDanhSach() {
    return _db.collection('lop').snapshots().map((snapshot) {
      final danhSach = snapshot.docs.map((doc) {
        return LopHanhChinh.fromMap(doc.id, doc.data());
      }).toList();

      danhSach.sort((a, b) => a.maLop.compareTo(b.maLop));

      return danhSach;
    });
  }

  Future<void> themLop(LopHanhChinh lop) async {
    final maLop = lop.maLop.trim().toUpperCase();
    final tenLop = lop.tenLop.trim();
    final khoaHoc = lop.khoaHoc.trim();

    if (!RegExp(r'^[A-Z0-9_-]{1,30}$').hasMatch(maLop)) {
      throw Exception('Mã lớp không hợp lệ.');
    }

    if (tenLop.isEmpty || khoaHoc.isEmpty) {
      throw Exception('Vui lòng nhập đầy đủ thông tin.');
    }

    final lopMoi = LopHanhChinh(maLop: maLop, tenLop: tenLop, khoaHoc: khoaHoc);

    final document = _db.collection('lop').doc(maLop);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (snapshot.exists) {
        throw Exception('Mã lớp đã tồn tại.');
      }

      transaction.set(document, lopMoi.toMap());
    });
  }
}
