class TongHopDiem {
  final double? diemTrungBinh;
  final int tongTinChiDaTinh;
  final int soMonDaCoDiem;
  final int soMonChuaCoDiem;

  const TongHopDiem({
    required this.diemTrungBinh,
    required this.tongTinChiDaTinh,
    required this.soMonDaCoDiem,
    required this.soMonChuaCoDiem,
  });

  bool get laTamTinh => soMonChuaCoDiem > 0;

  String get diemHienThi {
    final diem = diemTrungBinh;

    if (diem == null) return 'Chưa có điểm';

    return diem.toStringAsFixed(2);
  }

  String get xepLoai {
    final diem = diemTrungBinh;

    if (diem == null) return 'Chưa xếp loại';

    // Xếp loại theo giá trị gốc, không làm tròn trước.
    if (diem >= 9) return 'Xuất sắc';
    if (diem >= 8) return 'Giỏi';
    if (diem >= 7) return 'Khá';
    if (diem >= 5) return 'Trung bình';

    return 'Yếu';
  }
}

class ThongKeDiemService {
  // Truyền vào danh sách kết quả của một sinh viên
  // trong học kỳ và năm học đang chọn.
  static TongHopDiem tinh(Iterable<Map<String, dynamic>> danhSach) {
    double tongDiemNhanTinChi = 0;
    int tongTinChi = 0;
    int soMonDaCoDiem = 0;
    int soMonChuaCoDiem = 0;

    for (final data in danhSach) {
      final soTinChi = data['soTinChi'];
      final diem = data['diem'];

      if (soTinChi is! int || soTinChi <= 0) {
        throw const FormatException('Số tín chỉ phải là số nguyên lớn hơn 0.');
      }

      if (diem == null) {
        soMonChuaCoDiem++;
        continue;
      }

      if (diem is! num || !diem.isFinite || diem < 0 || diem > 10) {
        throw const FormatException('Điểm phải là số từ 0 đến 10.');
      }

      tongDiemNhanTinChi += diem.toDouble() * soTinChi;
      tongTinChi += soTinChi;
      soMonDaCoDiem++;
    }

    return TongHopDiem(
      diemTrungBinh: tongTinChi == 0 ? null : tongDiemNhanTinChi / tongTinChi,
      tongTinChiDaTinh: tongTinChi,
      soMonDaCoDiem: soMonDaCoDiem,
      soMonChuaCoDiem: soMonChuaCoDiem,
    );
  }
}
