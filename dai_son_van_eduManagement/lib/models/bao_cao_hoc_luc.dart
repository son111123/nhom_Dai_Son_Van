class BaoCaoHocLuc {
  final String namHoc;
  final int hocKy;
  final int tongSinhVien;
  final int soChuaCoDiem;
  final int soChoDuDiem;
  final Map<String, int> soLuongTheoXepLoai;
  final DateTime capNhatLuc;

  BaoCaoHocLuc({
    required this.namHoc,
    required this.hocKy,
    required this.tongSinhVien,
    required this.soChuaCoDiem,
    required this.soChoDuDiem,
    required Map<String, int> soLuongTheoXepLoai,
    required this.capNhatLuc,
  }) : soLuongTheoXepLoai = Map.unmodifiable(soLuongTheoXepLoai);

  int get soDaXepLoai {
    return soLuongTheoXepLoai.values.fold<int>(
      0,
      (tong, soLuong) => tong + soLuong,
    );
  }

  bool get soLieuKhop {
    return tongSinhVien == soDaXepLoai + soChuaCoDiem + soChoDuDiem;
  }
}
