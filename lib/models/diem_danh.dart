enum TrangThaiDiemDanh {
  coMat,
  vangMat,
  diMuon;

  String get nhan {
    switch (this) {
      case TrangThaiDiemDanh.coMat:
        return 'Có mặt';
      case TrangThaiDiemDanh.vangMat:
        return 'Vắng mặt';
      case TrangThaiDiemDanh.diMuon:
        return 'Đi muộn';
    }
  }

  static TrangThaiDiemDanh? tuGiaTri(String? giaTri) {
    if (giaTri == null) return null;

    return TrangThaiDiemDanh.values.firstWhere(
      (trangThai) => trangThai.name == giaTri,
      orElse: () =>
          throw FormatException('Trạng thái điểm danh không hợp lệ: $giaTri'),
    );
  }
}

class DiemDanh {
  final String maSV;
  final String hoTen;
  final TrangThaiDiemDanh? trangThai;
  final String ghiChu;

  const DiemDanh({
    required this.maSV,
    required this.hoTen,
    this.trangThai,
    this.ghiChu = '',
  });

  bool get daDiemDanh => trangThai != null;

  factory DiemDanh.fromMap(String maSV, Map<String, dynamic> data) {
    return DiemDanh(
      maSV: maSV,
      hoTen: data['hoTen'] as String? ?? '',
      trangThai: TrangThaiDiemDanh.tuGiaTri(data['trangThai'] as String?),
      ghiChu: data['ghiChu'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'hoTen': hoTen, 'trangThai': trangThai?.name, 'ghiChu': ghiChu};
  }
}
