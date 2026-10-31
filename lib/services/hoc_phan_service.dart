import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HocPhanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> layLopPhuTrach() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Bạn chưa đăng nhập.');
    }

    return _db
        .collection('lopHocPhan')
        .where('giangVienUid', isEqualTo: user.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> layDanhSachDiem(String maLHP) {
    return _db
        .collection('ketQua')
        .where('maLHP', isEqualTo: maLHP)
        .snapshots();
  }

  Future<void> luuDiem({
    required String id,
    required num? diemCu,
    required double diemMoi,
  }) async {
    if (!diemMoi.isFinite || diemMoi < 0 || diemMoi > 10) {
      throw Exception('Điểm phải nằm trong khoảng 0 đến 10.');
    }

    final document = _db.collection('ketQua').doc(id);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final data = snapshot.data();

      if (data == null) {
        throw Exception('Bản ghi kết quả không còn tồn tại.');
      }

      if (data['diem'] != diemCu) {
        throw Exception('Điểm đã thay đổi. Hãy đóng hộp thoại và mở lại.');
      }

      // Chi thay doi diem, giu nguyen thong tin ghi danh.
      transaction.update(document, {'diem': diemMoi});
    });
  }
}
