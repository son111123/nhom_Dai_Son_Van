import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/ket_qua_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả học tập')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _ketQuaStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Không tải được kết quả.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tatCa = snapshot.data!.docs;

          if (tatCa.isEmpty) {
            return const Center(child: Text('Bạn chưa có dữ liệu học tập.'));
          }

          // Kiem tra du lieu truoc khi dung de loc.
          final duLieuHopLe = tatCa.every((doc) {
            final data = doc.data();

            return data['namHoc'] is String &&
                data['hocKy'] is int &&
                data['tenMon'] is String &&
                data['soTinChi'] is num &&
                (data['diem'] == null || data['diem'] is num);
          });

          if (!duLieuHopLe) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Dữ liệu kết quả chưa đúng định dạng.\n'
                  'Vui lòng liên hệ quản trị viên.',
                  textAlign: TextAlign.center,
                ),
              ),
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
                          : '${doc.data()['diem']}',
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
