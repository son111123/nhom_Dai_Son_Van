import 'package:cloud_firestore/cloud_firestore.dart';

class KetQuaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> layKetQua(String maSV) {
    return _db.collection('ketQua').where('maSV', isEqualTo: maSV).snapshots();
  }
}
