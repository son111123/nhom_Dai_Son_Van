import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/buoi_hoc.dart';
import '../models/diem_danh.dart';
import '../models/thong_ke_chuyen_can.dart';

import 'package:firebase_auth/firebase_auth.dart';

class DiemDanhService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Đường dẫn: lopHocPhan/{maLHP}/buoiHoc
  CollectionReference<Map<String, dynamic>> _buoiHocRef(String maLHP) {
    if (maLHP.trim().isEmpty) {
      throw ArgumentError('Mã lớp học phần không được để trống.');
    }

    return _db.collection('lopHocPhan').doc(maLHP).collection('buoiHoc');
  }

  // Theo dõi danh sách buổi học, buổi mới nhất ở trên.
  Stream<List<BuoiHoc>> layDanhSachBuoi(String maLHP) {
    return _buoiHocRef(maLHP)
        .orderBy('ngayHoc', descending: true)
        .snapshots()
        .map((snapshot) {
          final danhSach = snapshot.docs.map((doc) {
            return BuoiHoc.fromMap(doc.id, doc.data());
          }).toList();

          // Các buổi cùng ngày được xếp theo tiết bắt đầu.
          danhSach.sort((a, b) {
            final soSanhNgay = b.ngayHoc.compareTo(a.ngayHoc);

            if (soSanhNgay != 0) return soSanhNgay;

            return a.tietBatDau.compareTo(b.tietBatDau);
          });

          return danhSach;
        });
  }

  // Theo dõi danh sách điểm danh của một buổi học.
  // Đường dẫn:
  // lopHocPhan/{maLHP}/buoiHoc/{maBuoi}/diemDanh
  Stream<List<DiemDanh>> layDiemDanh({
    required String maLHP,
    required String maBuoi,
  }) {
    if (maBuoi.trim().isEmpty) {
      throw ArgumentError('Mã buổi học không được để trống.');
    }

    return _buoiHocRef(maLHP)
        .doc(maBuoi)
        .collection('diemDanh')
        .snapshots()
        .map((snapshot) {
          final danhSach = snapshot.docs.map((doc) {
            return DiemDanh.fromMap(doc.id, doc.data());
          }).toList();

          danhSach.sort((a, b) => a.maSV.compareTo(b.maSV));

          return danhSach;
        });
  }

  Future<String> taoBuoiHoc({
    required String maLHP,
    required DateTime ngayHoc,
    required int tietBatDau,
    required int soTiet,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    if (tietBatDau < 1 || soTiet < 1) {
      throw Exception('Tiết bắt đầu và số tiết phải lớn hơn 0.');
    }

    // Chỉ giữ ngày, tháng, năm để các buổi cùng ngày
    // không bị khác nhau do giờ hoặc phút.
    final ngay = DateTime(ngayHoc.year, ngayHoc.month, ngayHoc.day);

    // Cùng lớp + cùng ngày + cùng tiết bắt đầu = cùng một buổi.
    final nam = ngay.year.toString().padLeft(4, '0');
    final thang = ngay.month.toString().padLeft(2, '0');
    final ngayTrongThang = ngay.day.toString().padLeft(2, '0');
    final maBuoi = '$nam$thang${ngayTrongThang}_$tietBatDau';

    final buoiRef = _buoiHocRef(maLHP).doc(maBuoi);
    final lopRef = _db.collection('lopHocPhan').doc(maLHP);

    // Lấy dữ liệu từ máy chủ để tránh dùng danh sách lưu đệm cũ.
    final ketQua = await _db
        .collection('ketQua')
        .where('maLHP', isEqualTo: maLHP)
        .get(const GetOptions(source: Source.server));

    final danhSach = <String, DiemDanh>{};

    for (final doc in ketQua.docs) {
      final data = doc.data();
      final maSV = data['maSV'] as String?;
      final hoTen = data['hoTen'] as String?;

      if (maSV == null ||
          !RegExp(r'^[A-Z0-9_-]{1,30}$').hasMatch(maSV) ||
          hoTen == null ||
          hoTen.trim().isEmpty) {
        throw Exception(
          'Thông tin sinh viên không hợp lệ ở bản ghi ${doc.id}.',
        );
      }

      // Dùng mã sinh viên làm khóa để tránh trùng danh sách.
      danhSach[maSV] = DiemDanh(maSV: maSV, hoTen: hoTen);
    }

    if (danhSach.isEmpty) {
      throw Exception('Lớp chưa có sinh viên để điểm danh.');
    }

    // Giới hạn của phiên bản này để lưu cả buổi trong một lần.
    if (danhSach.length > 400) {
      throw Exception('Phiên bản này hỗ trợ tối đa 400 sinh viên mỗi buổi.');
    }

    final buoiHoc = BuoiHoc(
      maBuoi: maBuoi,
      ngayHoc: ngay,
      tietBatDau: tietBatDau,
      soTiet: soTiet,
      nguoiTaoUid: user.uid,
    );

    await _db.runTransaction((transaction) async {
      // Đọc trước, ghi sau trong transaction.
      final lopSnapshot = await transaction.get(lopRef);
      final buoiSnapshot = await transaction.get(buoiRef);

      if (!lopSnapshot.exists) {
        throw Exception('Lớp học phần không tồn tại.');
      }

      if (lopSnapshot.data()?['giangVienUid'] != user.uid) {
        throw Exception('Bạn không phụ trách lớp học phần này.');
      }

      if (buoiSnapshot.exists) {
        throw Exception('Đã có buổi học vào ngày và tiết bắt đầu này.');
      }

      transaction.set(buoiRef, {
        ...buoiHoc.toMap(),
        'taoLuc': FieldValue.serverTimestamp(),
      });

      for (final diemDanh in danhSach.values) {
        final diemDanhRef = buoiRef.collection('diemDanh').doc(diemDanh.maSV);

        transaction.set(diemDanhRef, diemDanh.toMap());
      }
    });

    return maBuoi;
  }

  Future<void> luuDiemDanh({
    required String maLHP,
    required String maBuoi,
    required DiemDanh banCu,
    required TrangThaiDiemDanh? trangThai,
    required String ghiChu,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    if (maBuoi.trim().isEmpty || banCu.maSV.trim().isEmpty) {
      throw Exception('Thiếu mã buổi học hoặc mã sinh viên.');
    }

    final ghiChuMoi = ghiChu.trim();

    if (ghiChuMoi.length > 500) {
      throw Exception('Ghi chú không được vượt quá 500 ký tự.');
    }

    final lopRef = _db.collection('lopHocPhan').doc(maLHP);
    final buoiRef = _buoiHocRef(maLHP).doc(maBuoi);
    final diemDanhRef = buoiRef.collection('diemDanh').doc(banCu.maSV);

    await _db.runTransaction((transaction) async {
      final lopSnapshot = await transaction.get(lopRef);
      final buoiSnapshot = await transaction.get(buoiRef);
      final diemDanhSnapshot = await transaction.get(diemDanhRef);

      if (!lopSnapshot.exists ||
          lopSnapshot.data()?['giangVienUid'] != user.uid) {
        throw Exception('Bạn không phụ trách lớp học phần này.');
      }

      if (!buoiSnapshot.exists) {
        throw Exception('Buổi học không còn tồn tại.');
      }

      if (buoiSnapshot.data()?['trangThai'] != 'nhap') {
        throw Exception('Buổi học đã chốt, không thể sửa điểm danh.');
      }

      final data = diemDanhSnapshot.data();

      if (data == null) {
        throw Exception('Sinh viên không có trong danh sách buổi học.');
      }

      // Tránh ghi đè nếu dữ liệu đã được sửa ở thiết bị khác.
      if (data['trangThai'] != banCu.trangThai?.name ||
          data['ghiChu'] != banCu.ghiChu) {
        throw Exception('Điểm danh đã thay đổi. Hãy đóng biểu mẫu và mở lại.');
      }

      transaction.update(diemDanhRef, {
        'trangThai': trangThai?.name,
        'ghiChu': ghiChuMoi,
      });
    });
  }

  Future<void> chotBuoiHoc({
    required String maLHP,
    required String maBuoi,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    if (maBuoi.trim().isEmpty) {
      throw Exception('Thiếu mã buổi học.');
    }

    final lopRef = _db.collection('lopHocPhan').doc(maLHP);
    final buoiRef = _buoiHocRef(maLHP).doc(maBuoi);

    final danhSach = await buoiRef
        .collection('diemDanh')
        .get(const GetOptions(source: Source.server));

    if (danhSach.docs.isEmpty) {
      throw Exception('Buổi học chưa có danh sách sinh viên.');
    }

    await _db.runTransaction((transaction) async {
      final lopSnapshot = await transaction.get(lopRef);
      final buoiSnapshot = await transaction.get(buoiRef);

      if (!lopSnapshot.exists ||
          lopSnapshot.data()?['giangVienUid'] != user.uid) {
        throw Exception('Bạn không phụ trách lớp học phần này.');
      }

      if (!buoiSnapshot.exists) {
        throw Exception('Buổi học không còn tồn tại.');
      }

      if (buoiSnapshot.data()?['trangThai'] != 'nhap') {
        throw Exception('Buổi học đã được chốt.');
      }

      // Đọc lại từng bản ghi trong transaction để kiểm tra
      // dữ liệu mới nhất và phát hiện thay đổi đồng thời.
      var chuaDiemDanh = 0;

      for (final doc in danhSach.docs) {
        final snapshot = await transaction.get(doc.reference);

        if (!snapshot.exists) {
          throw Exception(
            'Danh sách sinh viên đã thay đổi. Hãy mở lại buổi học.',
          );
        }

        final trangThai = snapshot.data()?['trangThai'];

        if (!['coMat', 'vangMat', 'diMuon'].contains(trangThai)) {
          chuaDiemDanh++;
        }
      }

      if (chuaDiemDanh > 0) {
        throw Exception('Còn $chuaDiemDanh sinh viên chưa điểm danh.');
      }

      transaction.update(buoiRef, {
        'trangThai': 'daChot',
        'nguoiChotUid': user.uid,
        'chotLuc': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<List<ThongKeChuyenCan>> layThongKeChuyenCan(String maLHP) async {
    // Chỉ lấy những buổi đã hoàn tất điểm danh.
    final buoiSnapshot = await _buoiHocRef(maLHP)
        .where('trangThai', isEqualTo: 'daChot')
        .get(const GetOptions(source: Source.server));

    if (buoiSnapshot.docs.isEmpty) {
      return [];
    }

    final cacBuoi = buoiSnapshot.docs.toList();

    // Đọc từ buổi cũ đến buổi mới.
    // Họ tên hiển thị sẽ lấy từ buổi gần nhất có sinh viên đó.
    cacBuoi.sort((a, b) {
      final ngayA = (a.data()['ngayHoc'] as Timestamp).toDate();
      final ngayB = (b.data()['ngayHoc'] as Timestamp).toDate();

      final soSanhNgay = ngayA.compareTo(ngayB);

      if (soSanhNgay != 0) return soSanhNgay;

      final tietA = (a.data()['tietBatDau'] as num).toInt();
      final tietB = (b.data()['tietBatDau'] as num).toInt();

      return tietA.compareTo(tietB);
    });

    final thongKe = <String, ThongKeChuyenCan>{};

    for (final buoi in cacBuoi) {
      final diemDanhSnapshot = await buoi.reference
          .collection('diemDanh')
          .get(const GetOptions(source: Source.server));

      if (diemDanhSnapshot.docs.isEmpty) {
        throw Exception(
          'Buổi ${buoi.id} đã chốt nhưng không có danh sách điểm danh.',
        );
      }

      for (final doc in diemDanhSnapshot.docs) {
        final diemDanh = DiemDanh.fromMap(doc.id, doc.data());
        final trangThai = diemDanh.trangThai;

        if (trangThai == null) {
          throw Exception(
            'Buổi ${buoi.id}: sinh viên ${diemDanh.maSV} '
            'chưa được điểm danh dù buổi đã chốt.',
          );
        }

        final hienTai =
            thongKe[diemDanh.maSV] ??
            ThongKeChuyenCan(maSV: diemDanh.maSV, hoTen: diemDanh.hoTen);

        thongKe[diemDanh.maSV] = ThongKeChuyenCan(
          maSV: diemDanh.maSV,
          hoTen: diemDanh.hoTen,
          coMat: hienTai.coMat + (trangThai == TrangThaiDiemDanh.coMat ? 1 : 0),
          vangMat:
              hienTai.vangMat +
              (trangThai == TrangThaiDiemDanh.vangMat ? 1 : 0),
          diMuon:
              hienTai.diMuon + (trangThai == TrangThaiDiemDanh.diMuon ? 1 : 0),
        );
      }
    }

    final ketQua = thongKe.values.toList();
    ketQua.sort((a, b) => a.maSV.compareTo(b.maSV));

    return ketQua;
  }
}
