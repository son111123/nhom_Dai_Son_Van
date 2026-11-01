import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mon_hoc.dart';

class MonHocService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MonHoc>> layDanhSach() {
    return _db.collection('monHoc').snapshots().map((snapshot) {
      final danhSach = snapshot.docs.map((doc) {
        return MonHoc.fromMap(doc.id, doc.data());
      }).toList();

      danhSach.sort((a, b) => a.maMon.compareTo(b.maMon));

      return danhSach;
    });
  }

  Future<void> themMonHoc(MonHoc mon) async {
    final maMon = mon.maMon.trim().toUpperCase();
    final tenMon = mon.tenMon.trim();

    if (!RegExp(r'^[A-Z0-9_-]{1,30}$').hasMatch(maMon)) {
      throw Exception('Mã môn học không hợp lệ.');
    }

    if (tenMon.isEmpty) {
      throw Exception('Vui lòng nhập tên môn học.');
    }

    if (mon.soTinChi <= 0) {
      throw Exception('Số tín chỉ phải là số nguyên dương.');
    }

    final monMoi = MonHoc(maMon: maMon, tenMon: tenMon, soTinChi: mon.soTinChi);

    final document = _db.collection('monHoc').doc(maMon);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (snapshot.exists) {
        throw Exception('Mã môn học đã tồn tại.');
      }

      transaction.set(document, monMoi.toMap());
    });
  }
}
