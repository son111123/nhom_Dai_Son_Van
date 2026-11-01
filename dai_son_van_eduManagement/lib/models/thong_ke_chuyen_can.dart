class ThongKeChuyenCan {
  final String maSV;
  final String hoTen;
  final int coMat;
  final int vangMat;
  final int diMuon;

  const ThongKeChuyenCan({
    required this.maSV,
    required this.hoTen,
    this.coMat = 0,
    this.vangMat = 0,
    this.diMuon = 0,
  });

  int get tongBuoi => coMat + vangMat + diMuon;

  double? get tyLeChuyenCan {
    if (tongBuoi == 0) return null;

    return (coMat + diMuon) / tongBuoi * 100;
  }

  String get tyLeHienThi {
    final tyLe = tyLeChuyenCan;

    if (tyLe == null) return 'Chưa có dữ liệu';

    return '${tyLe.toStringAsFixed(1)}%';
  }
}
