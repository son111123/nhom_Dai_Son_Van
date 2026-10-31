class MonHoc {
  final String maMon;
  final String tenMon;
  final int soTinChi;

  MonHoc({required this.maMon, required this.tenMon, required this.soTinChi});

  factory MonHoc.fromMap(String id, Map<String, dynamic> data) {
    return MonHoc(
      maMon: id,
      tenMon: data['tenMon'] as String? ?? '',
      soTinChi: (data['soTinChi'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'tenMon': tenMon, 'soTinChi': soTinChi};
  }
}
