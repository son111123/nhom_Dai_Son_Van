import 'package:cloud_firestore/cloud_firestore.dart';

class LichHoc {
  final String maLich;
  final String maLHP;
  final String tenMon;
  final String giangVienUid;
  final String tenGiangVien;
  final String phongHoc;
  final DateTime batDau;
  final DateTime ketThuc;

  const LichHoc({
    required this.maLich,
    required this.maLHP,
    required this.tenMon,
    required this.giangVienUid,
    required this.tenGiangVien,
    required this.phongHoc,
    required this.batDau,
    required this.ketThuc,
  });

  Duration get thoiLuong => ketThuc.difference(batDau);

  String get thuHienThi {
    switch (batDau.weekday) {
      case DateTime.monday:
        return 'Thứ hai';
      case DateTime.tuesday:
        return 'Thứ ba';
      case DateTime.wednesday:
        return 'Thứ tư';
      case DateTime.thursday:
        return 'Thứ năm';
      case DateTime.friday:
        return 'Thứ sáu';
      case DateTime.saturday:
        return 'Thứ bảy';
      case DateTime.sunday:
        return 'Chủ nhật';
      default:
        throw StateError('Ngày học không hợp lệ.');
    }
  }

  void kiemTraHopLe() {
    if (maLHP.trim().isEmpty) {
      throw ArgumentError('Chưa chọn lớp học phần.');
    }

    if (tenMon.trim().isEmpty) {
      throw ArgumentError('Thiếu tên môn học.');
    }

    if (giangVienUid.trim().isEmpty || tenGiangVien.trim().isEmpty) {
      throw ArgumentError('Thiếu thông tin giảng viên.');
    }

    if (phongHoc.trim().isEmpty) {
      throw ArgumentError('Vui lòng nhập phòng học.');
    }

    if (!ketThuc.isAfter(batDau)) {
      throw ArgumentError('Thời gian kết thúc phải sau thời gian bắt đầu.');
    }
  }

  factory LichHoc.fromMap(String maLich, Map<String, dynamic> data) {
    final lich = LichHoc(
      maLich: maLich,
      maLHP: data['maLHP'] as String,
      tenMon: data['tenMon'] as String,
      giangVienUid: data['giangVienUid'] as String,
      tenGiangVien: data['tenGiangVien'] as String,
      phongHoc: data['phongHoc'] as String,
      batDau: (data['batDau'] as Timestamp).toDate(),
      ketThuc: (data['ketThuc'] as Timestamp).toDate(),
    );

    lich.kiemTraHopLe();

    return lich;
  }

  Map<String, dynamic> toMap() {
    kiemTraHopLe();

    return {
      'maLHP': maLHP,
      'tenMon': tenMon,
      'giangVienUid': giangVienUid,
      'tenGiangVien': tenGiangVien,
      'phongHoc': phongHoc.trim(),
      'batDau': Timestamp.fromDate(batDau),
      'ketThuc': Timestamp.fromDate(ketThuc),
    };
  }
}
