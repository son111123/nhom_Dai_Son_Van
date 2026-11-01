import 'package:cloud_firestore/cloud_firestore.dart';

enum TrangThaiBuoiHoc {
  nhap,
  daChot;

  String get nhan {
    switch (this) {
      case TrangThaiBuoiHoc.nhap:
        return 'Nháp';
      case TrangThaiBuoiHoc.daChot:
        return 'Đã chốt';
    }
  }

  static TrangThaiBuoiHoc tuGiaTri(String giaTri) {
    return TrangThaiBuoiHoc.values.firstWhere(
      (trangThai) => trangThai.name == giaTri,
      orElse: () =>
          throw FormatException('Trạng thái buổi học không hợp lệ: $giaTri'),
    );
  }
}

class BuoiHoc {
  final String maBuoi;
  final DateTime ngayHoc;
  final int tietBatDau;
  final int soTiet;
  final TrangThaiBuoiHoc trangThai;
  final String nguoiTaoUid;

  const BuoiHoc({
    required this.maBuoi,
    required this.ngayHoc,
    required this.tietBatDau,
    required this.soTiet,
    required this.nguoiTaoUid,
    this.trangThai = TrangThaiBuoiHoc.nhap,
  });

  bool get daChot => trangThai == TrangThaiBuoiHoc.daChot;

  int get tietKetThuc => tietBatDau + soTiet - 1;

  factory BuoiHoc.fromMap(String maBuoi, Map<String, dynamic> data) {
    return BuoiHoc(
      maBuoi: maBuoi,
      ngayHoc: (data['ngayHoc'] as Timestamp).toDate(),
      tietBatDau: (data['tietBatDau'] as num).toInt(),
      soTiet: (data['soTiet'] as num).toInt(),
      trangThai: TrangThaiBuoiHoc.tuGiaTri(data['trangThai'] as String),
      nguoiTaoUid: data['nguoiTaoUid'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    if (tietBatDau < 1 || soTiet < 1) {
      throw ArgumentError('Tiết bắt đầu và số tiết phải lớn hơn hoặc bằng 1.');
    }

    return {
      'ngayHoc': Timestamp.fromDate(ngayHoc),
      'tietBatDau': tietBatDau,
      'soTiet': soTiet,
      'trangThai': trangThai.name,
      'nguoiTaoUid': nguoiTaoUid,
    };
  }
}
