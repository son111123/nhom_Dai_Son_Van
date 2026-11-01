import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/lich_hoc.dart';
import '../../services/lich_hoc_service.dart';
import '../../services/ket_qua_service.dart';

class ThoiKhoaBieuScreen extends StatefulWidget {
  final String vaiTro;
  final String? maSV;
  final String? maLHP;

  const ThoiKhoaBieuScreen({
    super.key,
    required this.vaiTro,
    this.maSV,
    this.maLHP,
  });

  @override
  State<ThoiKhoaBieuScreen> createState() => _ThoiKhoaBieuScreenState();
}

class _ThoiKhoaBieuScreenState extends State<ThoiKhoaBieuScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _ghiDanh;

  String? _lopDaChon;

  @override
  void initState() {
    super.initState();

    if (widget.vaiTro == 'student' && widget.maSV != null) {
      _ghiDanh = KetQuaService().layKetQua(widget.maSV!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thời khóa biểu')),
      body: widget.vaiTro == 'student'
          ? _lichSinhVien()
          : BangLichHoc(vaiTro: widget.vaiTro, maLHP: widget.maLHP),
    );
  }

  Widget _lichSinhVien() {
    if (_ghiDanh == null) {
      return const Center(child: Text('Chưa liên kết mã sinh viên.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _ghiDanh,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Không đọc được danh sách ghi danh.\n'
                'Kiểm tra kết nối và quyền truy cập.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final cacLop = <String, String>{};

        for (final doc in snapshot.data!.docs) {
          final data = doc.data();
          final ma = data['maLHP'];

          if (ma is String && ma.isNotEmpty) {
            cacLop[ma] = '${data['tenMon'] ?? ma} — $ma';
          }
        }

        if (cacLop.isEmpty) {
          return const Center(
            child: Text('Bạn chưa được ghi danh lớp học phần.'),
          );
        }

        final cacMa = cacLop.keys.toList()..sort();

        final ma = cacLop.containsKey(_lopDaChon) ? _lopDaChon! : cacMa.first;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                key: ValueKey(ma),
                initialValue: ma,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Lớp học phần đã ghi danh',
                  border: OutlineInputBorder(),
                ),
                items: cacMa.map((id) {
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(cacLop[id]!, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _lopDaChon = value;
                  });
                },
              ),
            ),
            Expanded(
              child: BangLichHoc(
                key: ValueKey(ma),
                vaiTro: 'student',
                maLHP: ma,
              ),
            ),
          ],
        );
      },
    );
  }
}

class BangLichHoc extends StatefulWidget {
  final String vaiTro;
  final String? maLHP;

  const BangLichHoc({super.key, required this.vaiTro, this.maLHP});

  @override
  State<BangLichHoc> createState() => _BangLichHocState();
}

class _BangLichHocState extends State<BangLichHoc> {
  late Stream<List<LichHoc>> _stream;
  late DateTime _dauTuan;

  bool _tatCa = false;

  DateTime _thuHai(DateTime ngay) {
    return DateTime(ngay.year, ngay.month, ngay.day - ngay.weekday + 1);
  }

  @override
  void initState() {
    super.initState();

    _dauTuan = _thuHai(DateTime.now());
    _taiLai();
  }

  void _taiLai() {
    final service = LichHocService();

    if (widget.vaiTro == 'teacher') {
      // Giang vien chi doc lich theo UID dang dang nhap.
      _stream = service.layLichGiangVien().map((danhSach) {
        if (widget.maLHP == null) {
          return danhSach;
        }

        return danhSach.where((lich) => lich.maLHP == widget.maLHP).toList();
      });
    } else if (widget.maLHP != null) {
      _stream = service.layLichTheoLop(widget.maLHP!);
    } else if (widget.vaiTro == 'admin') {
      _stream = service.layTatCa();
    } else {
      _stream = Stream<List<LichHoc>>.error(
        StateError('Chưa chọn lớp học phần.'),
      );
    }
  }

  String _ngay(DateTime ngay) {
    final ngayTrongThang = ngay.day.toString().padLeft(2, '0');
    final thang = ngay.month.toString().padLeft(2, '0');

    return '$ngayTrongThang/$thang/${ngay.year}';
  }

  String _gio(DateTime ngay) {
    final gio = ngay.hour.toString().padLeft(2, '0');
    final phut = ngay.minute.toString().padLeft(2, '0');

    return '$gio:$phut';
  }

  @override
  Widget build(BuildContext context) {
    final cuoiTuan = DateTime(_dauTuan.year, _dauTuan.month, _dauTuan.day + 7);

    final chuNhat = DateTime(_dauTuan.year, _dauTuan.month, _dauTuan.day + 6);

    return Column(
      children: [
        SwitchListTile(
          title: const Text('Xem tất cả lịch học'),
          value: _tatCa,
          onChanged: (value) {
            setState(() {
              _tatCa = value;
            });
          },
        ),

        if (!_tatCa) ...[
          Row(
            children: [
              IconButton(
                tooltip: 'Tuần trước',
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _dauTuan = DateTime(
                      _dauTuan.year,
                      _dauTuan.month,
                      _dauTuan.day - 7,
                    );
                  });
                },
              ),
              Expanded(
                child: Text(
                  '${_ngay(_dauTuan)} – ${_ngay(chuNhat)}',
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                tooltip: 'Tuần sau',
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _dauTuan = cuoiTuan;
                  });
                },
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _dauTuan = _thuHai(DateTime.now());
              });
            },
            child: const Text('Tuần hiện tại'),
          ),
        ],

        Expanded(
          child: StreamBuilder<List<LichHoc>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Không tải được lịch học. '
                          'Kiểm tra mạng, dữ liệu và Firestore Rules.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            setState(_taiLai);
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final danhSach = snapshot.data!.where((lich) {
                return _tatCa ||
                    (!lich.batDau.isBefore(_dauTuan) &&
                        lich.batDau.isBefore(cuoiTuan));
              }).toList();

              if (danhSach.isEmpty) {
                return Center(
                  child: Text(
                    _tatCa
                        ? 'Chưa có lịch học.'
                        : 'Không có lịch học trong tuần này.',
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: danhSach.length,
                itemBuilder: (context, index) {
                  final lich = danhSach[index];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${lich.thuHienThi}, ${_ngay(lich.batDau)}',
                            style: const TextStyle(
                              color: Color(0xFF5140E8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lich.tenMon,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Lớp: ${lich.maLHP}'),
                          Text(
                            'Thời gian: ${_gio(lich.batDau)}'
                            ' – ${_gio(lich.ketThuc)}',
                          ),
                          Text('Phòng: ${lich.phongHoc}'),
                          Text('Giảng viên: ${lich.tenGiangVien}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
