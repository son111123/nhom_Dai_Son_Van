class SinhVien {
  final String maSV;
  final String hoTen;
  final String ngaySinh;
  final String soDienThoai;
  final String maLop;

  SinhVien({
    required this.maSV,
    required this.hoTen,
    required this.ngaySinh,
    required this.soDienThoai,
    required this.maLop,
  });

  factory SinhVien.fromMap(String id, Map<String, dynamic> data) {
    return SinhVien(
      maSV: id,
      hoTen: data['hoTen'] as String? ?? '',
      ngaySinh: data['ngaySinh'] as String? ?? '',
      soDienThoai: data['soDienThoai'] as String? ?? '',
      maLop: data['maLop'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hoTen': hoTen,
      'ngaySinh': ngaySinh,
      'soDienThoai': soDienThoai,
      'maLop': maLop,
    };
  }
}
