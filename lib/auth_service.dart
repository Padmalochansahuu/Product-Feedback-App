import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> setupPredefinedUsers() async {
    const users = [
      {'email': 'user@gmail.com', 'password': '123456'},
      {'email': 'admin@gmail.com', 'password': '1234567'},
    ];

    for (var user in users) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: user['email']!,
          password: user['password']!,
        );
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          await _auth.signInWithEmailAndPassword(
            email: user['email']!,
            password: user['password']!,
          );
        }
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Failed', e.message ?? 'An unknown error occurred.');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}