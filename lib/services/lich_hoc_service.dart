import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/lich_hoc.dart';

class LichHocService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _lichRef {
    return _db.collection('lichHoc');
  }

  Stream<List<LichHoc>> _docDanhSach(Query<Map<String, dynamic>> query) {
    return query.snapshots().map((snapshot) {
      final danhSach = snapshot.docs.map((doc) {
        return LichHoc.fromMap(doc.id, doc.data());
      }).toList();

      danhSach.sort((a, b) {
        final soSanhGio = a.batDau.compareTo(b.batDau);

        if (soSanhGio != 0) return soSanhGio;

        return a.maLHP.compareTo(b.maLHP);
      });

      return danhSach;
    });
  }

  // Dành cho quản trị viên.
  Stream<List<LichHoc>> layTatCa() {
    return _docDanhSach(_lichRef);
  }

  // Dùng khi xem thời khóa biểu của một lớp học phần.
  Stream<List<LichHoc>> layLichTheoLop(String maLHP) {
    final ma = maLHP.trim().toUpperCase();

    if (!RegExp(r'^[A-Z0-9-]{1,30}$').hasMatch(ma)) {
      throw ArgumentError('Mã lớp học phần không hợp lệ.');
    }

    return _docDanhSach(_lichRef.where('maLHP', isEqualTo: ma));
  }

  // Dành cho giảng viên đang đăng nhập.
  Stream<List<LichHoc>> layLichGiangVien() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    return _docDanhSach(_lichRef.where('giangVienUid', isEqualTo: user.uid));
  }

  DateTime _layDenPhut(DateTime value) {
    final local = value.toLocal();

    return DateTime(
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    );
  }

  String _haiSo(int value) {
    return value.toString().padLeft(2, '0');
  }

  Future<String> taoLichHoc({
    required String maLHP,
    required String phongHoc,
    required DateTime batDau,
    required DateTime ketThuc,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    final ma = maLHP.trim().toUpperCase();
    final phong = phongHoc.trim().toUpperCase();
    final tuLuc = _layDenPhut(batDau);
    final denLuc = _layDenPhut(ketThuc);

    if (!RegExp(r'^[A-Z0-9-]{1,30}$').hasMatch(ma)) {
      throw Exception('Mã lớp học phần không hợp lệ.');
    }

    if (phong.isEmpty || phong.length > 50) {
      throw Exception('Nhập phòng học từ 1 đến 50 ký tự.');
    }

    if (!denLuc.isAfter(tuLuc)) {
      throw Exception('Giờ kết thúc phải sau giờ bắt đầu.');
    }

    if (tuLuc.year != denLuc.year ||
        tuLuc.month != denLuc.month ||
        tuLuc.day != denLuc.day) {
      throw Exception('Một buổi học phải bắt đầu và kết thúc cùng ngày.');
    }

    final ngayId = [
      tuLuc.year.toString().padLeft(4, '0'),
      _haiSo(tuLuc.month),
      _haiSo(tuLuc.day),
    ].join();

    final gioId = '${_haiSo(tuLuc.hour)}${_haiSo(tuLuc.minute)}';
    final maLich = '${ma}_${ngayId}_$gioId';

    final lichRef = _lichRef.doc(maLich);
    final lopRef = _db.collection('lopHocPhan').doc(ma);
    final nguoiTaoRef = _db.collection('users').doc(user.uid);

    await _db.runTransaction((transaction) async {
      final nguoiTao = await transaction.get(nguoiTaoRef);

      if (nguoiTao.data()?['role'] != 'admin') {
        throw Exception('Chỉ quản trị viên được tạo lịch học.');
      }

      final lop = await transaction.get(lopRef);
      final lichCu = await transaction.get(lichRef);

      if (!lop.exists) {
        throw Exception('Lớp học phần không tồn tại.');
      }

      if (lichCu.exists) {
        throw Exception('Lớp đã có lịch bắt đầu vào thời điểm này.');
      }

      final lopData = lop.data()!;
      final tenMon = lopData['tenMon'];
      final giangVienUid = lopData['giangVienUid'];

      if (tenMon is! String || tenMon.trim().isEmpty) {
        throw Exception('Lớp học phần thiếu tên môn học.');
      }

      if (giangVienUid is! String || giangVienUid.trim().isEmpty) {
        throw Exception('Lớp chưa được phân công giảng viên.');
      }

      final giangVien = await transaction.get(
        _db.collection('users').doc(giangVienUid),
      );

      final gvData = giangVien.data();

      if (gvData == null || gvData['role'] != 'teacher') {
        throw Exception('Giảng viên phụ trách không hợp lệ.');
      }

      final tenGiangVien = gvData['hoTen'];

      if (tenGiangVien is! String || tenGiangVien.trim().isEmpty) {
        throw Exception('Tài khoản giảng viên chưa có họ tên.');
      }

      final lich = LichHoc(
        maLich: maLich,
        maLHP: ma,
        tenMon: tenMon,
        giangVienUid: giangVienUid,
        tenGiangVien: tenGiangVien,
        phongHoc: phong,
        batDau: tuLuc,
        ketThuc: denLuc,
      );

      transaction.set(lichRef, {
        ...lich.toMap(),
        'nguoiTaoUid': user.uid,
        'taoLuc': FieldValue.serverTimestamp(),
      });
    });

    return maLich;
  }
}
