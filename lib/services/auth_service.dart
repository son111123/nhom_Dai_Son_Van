import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Getter de chi truy cap Firebase khi can.
  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Theo doi dang nhap / dang xuat.
  Stream<User?> theoDoiDangNhap() {
    return _auth.authStateChanges();
  }

  // Dang nhap bang email va mat khau.
  Future<void> dangNhap(String email, String matKhau) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: matKhau,
    );
  }

  // Doc ho so va vai tro theo UID.
  Stream<DocumentSnapshot<Map<String, dynamic>>> theoDoiTaiKhoan(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> dangXuat() async {
    await _auth.signOut();
  }
}
