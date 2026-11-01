import 'package:flutter/material.dart';

import '../../models/diem_danh.dart';
import '../../services/diem_danh_service.dart';

class DiemDanhScreen extends StatefulWidget {
  final String maLHP;
  final String maBuoi;
  final bool daChot;

  const DiemDanhScreen({
    super.key,
    required this.maLHP,
    required this.maBuoi,
    required this.daChot,
  });

  @override
  State<DiemDanhScreen> createState() => _DiemDanhScreenState();
}

class _DiemDanhScreenState extends State<DiemDanhScreen> {
  final _service = DiemDanhService();
  late Stream<List<DiemDanh>> _diemDanhStream;
  bool _dangChot = false;

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  void _taiDuLieu() {
    _diemDanhStream = _service.layDiemDanh(
      maLHP: widget.maLHP,
      maBuoi: widget.maBuoi,
    );
  }

  Future<void> _moDiemDanh(DiemDanh sinhVien) async {
    if (widget.daChot) return;

    final daLuu = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuaDiemDanhDialog(
        maLHP: widget.maLHP,
        maBuoi: widget.maBuoi,
        banCu: sinhVien,
      ),
    );

    if (!mounted || daLuu != true) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã lưu điểm danh.')));
  }

  Color _mauTrangThai(TrangThaiDiemDanh? trangThai) {
    switch (trangThai) {
      case TrangThaiDiemDanh.coMat:
        return Colors.green;
      case TrangThaiDiemDanh.vangMat:
        return Colors.red;
      case TrangThaiDiemDanh.diMuon:
        return Colors.orange;
      case null:
        return Colors.grey;
    }
  }

  Future<void> _chotBuoi() async {
    if (_dangChot || widget.daChot) return;

    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chốt buổi học?'),
        content: const Text(
          'Sau khi chốt, bạn chỉ có thể xem lại '
          'và không thể sửa điểm danh của buổi này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Chốt buổi'),
          ),
        ],
      ),
    );

    if (!mounted || dongY != true) return;

    setState(() => _dangChot = true);

    try {
      await _service.chotBuoiHoc(maLHP: widget.maLHP, maBuoi: widget.maBuoi);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã chốt buổi học.')));

      // Trở về danh sách; khi mở lại, buổi ở chế độ chỉ xem.
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _dangChot = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm danh sinh viên'),
        actions: [
          if (!widget.daChot)
            TextButton(
              onPressed: _dangChot ? null : _chotBuoi,
              child: Text(_dangChot ? 'Đang chốt...' : 'Chốt buổi'),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${widget.maLHP} · Buổi ${widget.maBuoi}\n'
              '${widget.daChot ? 'Đã chốt — chỉ xem' : 'Chọn sinh viên để điểm danh'}',
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DiemDanh>>(
              stream: _diemDanhStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Không tải được điểm danh.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              setState(_taiDuLieu);
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

                final danhSach = snapshot.data!;

                if (danhSach.isEmpty) {
                  return const Center(
                    child: Text('Buổi học chưa có danh sách sinh viên.'),
                  );
                }

                final daDiemDanh = danhSach.where((sv) => sv.daDiemDanh).length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Đã điểm danh: $daDiemDanh/${danhSach.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: danhSach.length,
                        itemBuilder: (context, index) {
                          final sv = danhSach[index];
                          final nhan = sv.trangThai?.nhan ?? 'Chưa điểm danh';

                          return Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.person_outline,
                                color: _mauTrangThai(sv.trangThai),
                              ),
                              title: Text('${sv.maSV} — ${sv.hoTen}'),
                              subtitle: Text(
                                sv.ghiChu.isEmpty
                                    ? nhan
                                    : '$nhan\nGhi chú: ${sv.ghiChu}',
                              ),
                              trailing: widget.daChot
                                  ? const Icon(Icons.lock_outline)
                                  : const Icon(Icons.edit_outlined),
                              onTap: widget.daChot || _dangChot
                                  ? null
                                  : () => _moDiemDanh(sv),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SuaDiemDanhDialog extends StatefulWidget {
  final String maLHP;
  final String maBuoi;
  final DiemDanh banCu;

  const SuaDiemDanhDialog({
    super.key,
    required this.maLHP,
    required this.maBuoi,
    required this.banCu,
  });

  @override
  State<SuaDiemDanhDialog> createState() => _SuaDiemDanhDialogState();
}

class _SuaDiemDanhDialogState extends State<SuaDiemDanhDialog> {
  final _service = DiemDanhService();

  late final TextEditingController _ghiChuController;
  late TrangThaiDiemDanh? _trangThai;

  bool _dangLuu = false;
  String? _loi;

  @override
  void initState() {
    super.initState();
    _trangThai = widget.banCu.trangThai;
    _ghiChuController = TextEditingController(text: widget.banCu.ghiChu);
  }

  @override
  void dispose() {
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _luu() async {
    if (_dangLuu) return;

    setState(() {
      _dangLuu = true;
      _loi = null;
    });

    try {
      await _service.luuDiemDanh(
        maLHP: widget.maLHP,
        maBuoi: widget.maBuoi,
        banCu: widget.banCu,
        trangThai: _trangThai,
        ghiChu: _ghiChuController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loi = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _dangLuu = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dangLuu,
      child: AlertDialog(
        title: const Text('Ghi nhận điểm danh'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${widget.banCu.maSV} — ${widget.banCu.hoTen}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _trangThai?.name ?? 'chuaDiemDanh',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'chuaDiemDanh',
                    child: Text('Chưa điểm danh'),
                  ),
                  ...TrangThaiDiemDanh.values.map(
                    (trangThai) => DropdownMenuItem(
                      value: trangThai.name,
                      child: Text(trangThai.nhan),
                    ),
                  ),
                ],
                onChanged: _dangLuu
                    ? null
                    : (value) {
                        setState(() {
                          _trangThai = value == 'chuaDiemDanh'
                              ? null
                              : TrangThaiDiemDanh.tuGiaTri(value);
                        });
                      },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ghiChuController,
                enabled: !_dangLuu,
                maxLength: 500,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Ví dụ: Đi muộn 10 phút',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_loi != null) ...[
                const SizedBox(height: 12),
                Text(
                  _loi!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _dangLuu ? null : () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: _dangLuu ? null : _luu,
            child: Text(_dangLuu ? 'Đang lưu...' : 'Lưu'),
          ),
        ],
      ),
    );
  }
}
