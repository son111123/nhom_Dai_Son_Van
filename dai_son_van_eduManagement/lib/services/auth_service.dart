import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<User?> theoDoiDangNhap() {
    return _auth.authStateChanges();
  }

  Future<void> dangNhap(String email, String matKhau) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: matKhau,
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> theoDoiTaiKhoan(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> dangKy({
    required String hoTen,
    required String email,
    required String matKhau,
  }) async {
    final ten = hoTen.trim();
    final emailChuan = email.trim();

    if (ten.isEmpty || ten.length > 100) {
      throw Exception('Họ tên phải từ 1 đến 100 ký tự.');
    }

    final ketQua = await _auth.createUserWithEmailAndPassword(
      email: emailChuan,
      password: matKhau,
    );

    final user = ketQua.user;

    if (user == null) {
      throw Exception('Không tạo được tài khoản.');
    }

    try {
      // Tai khoan moi chi duoc tao voi vai tro pending.
      await _db.collection('users').doc(user.uid).set({
        'hoTen': ten,
        'email': user.email,
        'role': 'pending',
        'taoLuc': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Auth va Firestore khong nam trong cung transaction.
      // Thu xoa tai khoan Auth neu tao ho so that bai.
      try {
        await user.delete();
      } catch (_) {
        throw Exception(
          'Đã tạo tài khoản đăng nhập nhưng chưa lưu được hồ sơ. '
          'Hãy liên hệ quản trị viên để hoàn tất hồ sơ.',
        );
      }

      throw Exception(
        'Không lưu được hồ sơ. Kiểm tra mạng và Firestore Rules, '
        'sau đó đăng ký lại.',
      );
    }
  }

  Future<void> quenMatKhau(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Khong tiet lo email co tai khoan hay khong.
      if (e.code != 'user-not-found') {
        rethrow;
      }
    }
  }

  Future<void> dangXuat() async {
    await _auth.signOut();
  }
}
