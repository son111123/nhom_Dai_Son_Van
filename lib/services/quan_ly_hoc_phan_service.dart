import 'package:cloud_firestore/cloud_firestore.dart';

class QuanLyHocPhanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> layDanhSach() {
    return _db.collection('lopHocPhan').snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> layMonHoc() {
    return _db.collection('monHoc').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> layGiangVien() {
    return _db.collection('users').where('role', isEqualTo: 'teacher').get();
  }

  Future<void> taoLop({
    required String maLHP,
    required String maMon,
    required String giangVienUid,
    required int hocKy,
    required String namHoc,
  }) async {
    final ma = maLHP.trim().toUpperCase();
    final maMonChuan = maMon.trim().toUpperCase();
    final nam = namHoc.trim();

    if (!RegExp(r'^[A-Z0-9-]{1,30}$').hasMatch(ma)) {
      throw Exception('Mã lớp chỉ gồm chữ không dấu, số và dấu -.');
    }

    if (!RegExp(r'^[A-Z0-9_-]{1,30}$').hasMatch(maMonChuan)) {
      throw Exception('Mã môn học không hợp lệ.');
    }

    if (giangVienUid.trim().isEmpty) {
      throw Exception('Vui lòng chọn giảng viên phụ trách.');
    }

    if (![1, 2, 3].contains(hocKy)) {
      throw Exception('Học kỳ không hợp lệ.');
    }

    if (!RegExp(r'^[0-9]{4}-[0-9]{4}$').hasMatch(nam)) {
      throw Exception('Năm học phải có dạng 2026-2027.');
    }

    final cacNam = nam.split('-');

    if (int.parse(cacNam[1]) != int.parse(cacNam[0]) + 1) {
      throw Exception('Hai năm phải liên tiếp.');
    }

    final lopRef = _db.collection('lopHocPhan').doc(ma);
    final monRef = _db.collection('monHoc').doc(maMonChuan);
    final gvRef = _db.collection('users').doc(giangVienUid);

    await _db.runTransaction((transaction) async {
      final lop = await transaction.get(lopRef);
      final mon = await transaction.get(monRef);
      final gv = await transaction.get(gvRef);

      if (lop.exists) {
        throw Exception('Mã lớp học phần đã tồn tại.');
      }

      if (!mon.exists) {
        throw Exception('Môn học không tồn tại.');
      }

      if (!gv.exists || gv.data()?['role'] != 'teacher') {
        throw Exception('Tài khoản được chọn không phải giảng viên.');
      }

      final monData = mon.data()!;
      final tenMon = monData['tenMon'];
      final soTinChi = monData['soTinChi'];

      if (tenMon is! String ||
          tenMon.trim().isEmpty ||
          soTinChi is! int ||
          soTinChi <= 0) {
        throw Exception('Thông tin môn học không hợp lệ.');
      }

      // Khóa môn trước khi sử dụng cho lớp học phần.
      // Cùng transaction nên hai thao tác thành công hoặc thất bại cùng nhau.
      transaction.update(monRef, {'daSuDung': true});

      transaction.set(lopRef, {
        'maMon': maMonChuan,
        'tenMon': tenMon,
        'giangVienUid': giangVienUid,
        'hocKy': hocKy,
        'namHoc': nam,
      });
    });
  }

  Future<void> ghiDanh({required String maLHP, required String maSV}) async {
    final ma = maSV.trim().toUpperCase();

    if (!RegExp(r'^[A-Z0-9_-]{1,30}$').hasMatch(ma)) {
      throw Exception('Mã sinh viên không hợp lệ.');
    }

    final lopRef = _db.collection('lopHocPhan').doc(maLHP);
    final svRef = _db.collection('sinhVien').doc(ma);
    final ketQuaRef = _db.collection('ketQua').doc('${ma}_$maLHP');

    await _db.runTransaction((transaction) async {
      final lop = await transaction.get(lopRef);
      final sv = await transaction.get(svRef);
      final ketQua = await transaction.get(ketQuaRef);

      if (!lop.exists) {
        throw Exception('Lớp học phần không tồn tại.');
      }

      if (!sv.exists) {
        throw Exception('Không tìm thấy sinh viên có mã $ma.');
      }

      if (ketQua.exists) {
        throw Exception(
          'Bản ghi đã tồn tại. Kiểm tra danh sách sinh viên của lớp.',
        );
      }

      final lopData = lop.data()!;

      final mon = await transaction.get(
        _db.collection('monHoc').doc(lopData['maMon'] as String),
      );

      if (!mon.exists) {
        throw Exception('Môn học của lớp không tồn tại.');
      }

      // Khoa xoa ho so khi sinh vien da duoc ghi danh.
      transaction.update(svRef, {'daGhiDanh': true});

      transaction.set(ketQuaRef, {
        'maSV': ma,
        'hoTen': sv.data()!['hoTen'],
        'maLHP': maLHP,
        'tenMon': lopData['tenMon'],
        'soTinChi': mon.data()!['soTinChi'],
        'hocKy': lopData['hocKy'],
        'namHoc': lopData['namHoc'],
        'diem': null,
      });
    });
  }
}
