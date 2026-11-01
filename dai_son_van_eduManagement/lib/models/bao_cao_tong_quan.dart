class ThongKeSinhVienTheoLop {
  final String maLop;
  final String tenLop;
  final int soSinhVien;

  const ThongKeSinhVienTheoLop({
    required this.maLop,
    required this.tenLop,
    required this.soSinhVien,
  });
}

class BaoCaoTongQuan {
  final int tongSinhVien;
  final int tongLopHocPhan;

  // Sinh viên thiếu mã lớp hoặc tham chiếu đến lớp không tồn tại.
  final int soSinhVienChuaXacDinhLop;

  final List<ThongKeSinhVienTheoLop> sinhVienTheoLop;

  // Thời điểm hoàn tất lấy dữ liệu báo cáo.
  final DateTime capNhatLuc;

  BaoCaoTongQuan({
    required this.tongSinhVien,
    required this.tongLopHocPhan,
    required this.soSinhVienChuaXacDinhLop,
    required List<ThongKeSinhVienTheoLop> sinhVienTheoLop,
    required this.capNhatLuc,
  }) : sinhVienTheoLop = List.unmodifiable(sinhVienTheoLop);

  // Danh sách phải bao gồm cả lớp chưa có sinh viên.
  int get tongLopHanhChinh => sinhVienTheoLop.length;

  int get soSinhVienDaXacDinhLop {
    return sinhVienTheoLop.fold<int>(0, (tong, lop) => tong + lop.soSinhVien);
  }

  bool get soLieuKhop {
    return tongSinhVien == soSinhVienDaXacDinhLop + soSinhVienChuaXacDinhLop;
  }
}
