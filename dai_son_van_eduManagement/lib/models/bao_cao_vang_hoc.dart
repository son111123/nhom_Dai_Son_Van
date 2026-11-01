class SinhVienVangHoc {
  final String maSV;
  final String hoTen;
  final int soLuotVang;
  final DateTime ngayVangGanNhat;

  const SinhVienVangHoc({
    required this.maSV,
    required this.hoTen,
    required this.soLuotVang,
    required this.ngayVangGanNhat,
  });
}

class BaoCaoVangHoc {
  final DateTime tuNgay;
  final DateTime denNgay;
  final int soBuoiDaChot;
  final DateTime capNhatLuc;
  final List<SinhVienVangHoc> danhSach;

  BaoCaoVangHoc({
    required this.tuNgay,
    required this.denNgay,
    required this.soBuoiDaChot,
    required this.capNhatLuc,
    required List<SinhVienVangHoc> danhSach,
  }) : danhSach = List.unmodifiable(danhSach);

  int get soSinhVienVang => danhSach.length;

  int get tongLuotVang {
    return danhSach.fold<int>(
      0,
      (tong, sinhVien) => tong + sinhVien.soLuotVang,
    );
  }
}
