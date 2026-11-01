import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/ket_qua_service.dart';
import '../../services/thong_ke_diem_service.dart';

class KetQuaScreen extends StatefulWidget {
  final String maSV;

  const KetQuaScreen({super.key, required this.maSV});

  @override
  State<KetQuaScreen> createState() => _KetQuaScreenState();
}

class _KetQuaScreenState extends State<KetQuaScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _ketQuaStream;

  String? _namHoc;
  int? _hocKy;

  @override
  void initState() {
    super.initState();
    _ketQuaStream = KetQuaService().layKetQua(widget.maSV);
  }

  Widget _thongBao(String noiDung) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(noiDung, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _theTongHop(TongHopDiem tongHop) {
    final coDiem = tongHop.diemTrungBinh != null;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng hợp học kỳ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              coDiem
                  ? 'Điểm trung bình: ${tongHop.diemHienThi}/10'
                  : 'Điểm trung bình: Chưa có điểm',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Xếp loại: ${tongHop.xepLoai}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('Số học phần đã có điểm: ${tongHop.soMonDaCoDiem}'),
            Text('Số học phần chưa có điểm: ${tongHop.soMonChuaCoDiem}'),
            Text('Tín chỉ được tính: ${tongHop.tongTinChiDaTinh}'),
            if (coDiem && tongHop.laTamTinh) ...[
              const SizedBox(height: 12),
              const Text(
                'Kết quả tạm tính vì còn học phần chưa có điểm.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Điểm trung bình tính theo tín chỉ. '
              'Xếp loại theo quy ước của dự án.',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả học tập')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _ketQuaStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _thongBao('Không tải được kết quả.\n${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tatCa = snapshot.data!.docs;

          if (tatCa.isEmpty) {
            return _thongBao('Bạn chưa có dữ liệu học tập.');
          }

          final duLieuHopLe = tatCa.every((doc) {
            final data = doc.data();
            final namHoc = data['namHoc'];
            final hocKy = data['hocKy'];
            final tenMon = data['tenMon'];
            final maLHP = data['maLHP'];
            final soTinChi = data['soTinChi'];
            final diem = data['diem'];

            return namHoc is String &&
                namHoc.trim().isNotEmpty &&
                hocKy is int &&
                [1, 2, 3].contains(hocKy) &&
                tenMon is String &&
                tenMon.trim().isNotEmpty &&
                maLHP is String &&
                maLHP.trim().isNotEmpty &&
                soTinChi is int &&
                soTinChi > 0 &&
                (diem == null ||
                    (diem is num && diem.isFinite && diem >= 0 && diem <= 10));
          });

          if (!duLieuHopLe) {
            return _thongBao(
              'Dữ liệu kết quả chưa đúng định dạng.\n'
              'Vui lòng liên hệ quản trị viên.',
            );
          }

          final cacNam =
              tatCa
                  .map((doc) => doc.data()['namHoc'] as String)
                  .toSet()
                  .toList()
                ..sort();

          final namDangChon = cacNam.contains(_namHoc) ? _namHoc! : cacNam.last;

          final theoNam = tatCa.where((doc) {
            return doc.data()['namHoc'] == namDangChon;
          }).toList();

          final cacKy =
              theoNam.map((doc) => doc.data()['hocKy'] as int).toSet().toList()
                ..sort();

          final kyDangChon = cacKy.contains(_hocKy) ? _hocKy! : cacKy.last;

          final danhSach = theoNam.where((doc) {
            return doc.data()['hocKy'] == kyDangChon;
          }).toList();

          danhSach.sort((a, b) {
            final tenA = a.data()['tenMon'] as String;
            final tenB = b.data()['tenMon'] as String;

            return tenA.compareTo(tenB);
          });

          final tongHop = ThongKeDiemService.tinh(
            danhSach.map((doc) => doc.data()),
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey('nam-$namDangChon'),
                initialValue: namDangChon,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Năm học',
                  border: OutlineInputBorder(),
                ),
                items: cacNam.map((nam) {
                  return DropdownMenuItem(value: nam, child: Text(nam));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _namHoc = value;
                    _hocKy = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                key: ValueKey('ky-$namDangChon-$kyDangChon'),
                initialValue: kyDangChon,
                decoration: const InputDecoration(
                  labelText: 'Học kỳ',
                  border: OutlineInputBorder(),
                ),
                items: cacKy.map((ky) {
                  return DropdownMenuItem(value: ky, child: Text('Học kỳ $ky'));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _hocKy = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              _theTongHop(tongHop),
              const SizedBox(height: 20),
              Text(
                'Điểm theo môn học',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final doc in danhSach)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.menu_book_outlined,
                      color: Colors.deepPurple,
                    ),
                    title: Text(doc.data()['tenMon'] as String),
                    subtitle: Text(
                      '${doc.data()['maLHP']}'
                      ' · ${doc.data()['soTinChi']} tín chỉ',
                    ),
                    trailing: Text(
                      doc.data()['diem'] == null
                          ? 'Chưa có điểm'
                          : (doc.data()['diem'] as num).toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
