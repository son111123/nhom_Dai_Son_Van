class LopHanhChinh {
  final String maLop;
  final String tenLop;
  final String khoaHoc;

  LopHanhChinh({
    required this.maLop,
    required this.tenLop,
    required this.khoaHoc,
  });

  // Chuyen du lieu Firestore thanh doi tuong.
  factory LopHanhChinh.fromMap(String id, Map<String, dynamic> data) {
    return LopHanhChinh(
      maLop: id,
      tenLop: data['tenLop'] as String? ?? '',
      khoaHoc: data['khoaHoc'] as String? ?? '',
    );
  }

  // Chuyen doi tuong thanh du lieu de luu Firestore.
  Map<String, dynamic> toMap() {
    return {'tenLop': tenLop, 'khoaHoc': khoaHoc};
  }
}
