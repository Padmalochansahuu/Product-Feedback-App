import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString userRole = 'User'.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, _loadUserRole);
  }

  Future<void> _loadUserRole(User? currentUser) async {
    if (currentUser != null) {
      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      userRole.value = doc.data()?['role'] ?? 'User';
    } else {
      userRole.value = 'User';
    }
  }

  Future<void> register({required String email, required String password, required String role}) async {
    isLoading.value = true;
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      userRole.value = role;
      Get.snackbar('Success', 'Registration successful!');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters long.';
          break;
        default:
          message = e.message ?? 'An unknown error occurred.';
      }
      Get.snackbar('Error', message);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'An unknown error occurred.');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    userRole.value = 'User';
  }

  bool isAdmin() {
    return userRole.value == 'Admin';
  }
}