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

  MonHoc _chuanHoa(MonHoc mon) {
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

    return MonHoc(maMon: maMon, tenMon: tenMon, soTinChi: mon.soTinChi);
  }

  void _kiemTraDuocThayDoi(Map<String, dynamic> data) {
    // Môn cũ chưa có cờ cần được kiểm tra trước khi mở sửa/xóa.
    if (!data.containsKey('daSuDung')) {
      throw Exception(
        'Môn học chưa được cập nhật trạng thái sử dụng. '
        'Cần kiểm tra lớp học phần liên quan trước khi sửa hoặc xóa.',
      );
    }

    if (data['daSuDung'] != false) {
      throw Exception(
        'Môn học đã được phân cho lớp học phần, '
        'không thể sửa hoặc xóa.',
      );
    }
  }

  void _kiemTraBanCu(Map<String, dynamic> data, MonHoc banCu) {
    if (data['tenMon'] != banCu.tenMon || data['soTinChi'] != banCu.soTinChi) {
      throw Exception(
        'Thông tin môn học đã thay đổi. '
        'Hãy đóng biểu mẫu và mở lại.',
      );
    }
  }

  Future<void> themMonHoc(MonHoc mon) async {
    final monMoi = _chuanHoa(mon);
    final document = _db.collection('monHoc').doc(monMoi.maMon);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (snapshot.exists) {
        throw Exception('Mã môn học đã tồn tại.');
      }

      transaction.set(document, {...monMoi.toMap(), 'daSuDung': false});
    });
  }

  Future<void> suaMonHoc({
    required MonHoc banCu,
    required MonHoc monMoi,
  }) async {
    final mon = _chuanHoa(monMoi);

    if (mon.maMon != banCu.maMon) {
      throw Exception('Không được thay đổi mã môn học.');
    }

    final document = _db.collection('monHoc').doc(banCu.maMon);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final data = snapshot.data();

      if (data == null) {
        throw Exception('Môn học không còn tồn tại.');
      }

      _kiemTraDuocThayDoi(data);
      _kiemTraBanCu(data, banCu);

      // Chỉ sửa tên và tín chỉ, giữ nguyên trạng thái sử dụng.
      transaction.update(document, {
        'tenMon': mon.tenMon,
        'soTinChi': mon.soTinChi,
      });
    });
  }

  Future<void> xoaMonHoc(MonHoc banCu) async {
    final document = _db.collection('monHoc').doc(banCu.maMon);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final data = snapshot.data();

      if (data == null) {
        throw Exception('Môn học không còn tồn tại.');
      }

      _kiemTraDuocThayDoi(data);
      _kiemTraBanCu(data, banCu);

      transaction.delete(document);
    });
  }
}
