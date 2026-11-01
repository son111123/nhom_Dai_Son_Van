import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TenGiangVienPhuTrach extends StatefulWidget {
  final String uid;

  const TenGiangVienPhuTrach({super.key, required this.uid});

  @override
  State<TenGiangVienPhuTrach> createState() => _TenGiangVienPhuTrachState();
}

class _TenGiangVienPhuTrachState extends State<TenGiangVienPhuTrach> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _stream;

  void _ganStream() {
    _stream = widget.uid.isEmpty
        ? null
        : FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _ganStream();
  }

  @override
  void didUpdateWidget(covariant TenGiangVienPhuTrach oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.uid != widget.uid) {
      _ganStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) {
      return const Text('Chưa phân công giảng viên');
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Không đọc được giảng viên phụ trách');
        }

        if (!snapshot.hasData) {
          return const Text('Đang tải giảng viên...');
        }

        final ten = snapshot.data!.data()?['hoTen'];

        final tenHienThi = ten is String && ten.trim().isNotEmpty
            ? ten
            : 'Chưa có họ tên';

        return Text('Giảng viên: $tenHienThi');
      },
    );
  }
}
