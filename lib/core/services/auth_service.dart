import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, _loadUserRole);
  }

  Future<void> _loadUserRole(User? currentUser) async {
    if (currentUser != null) {
      try {
        final doc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          userRole.value = doc.data()?['role'] ?? 'User';
        } else {
          userRole.value = 'User';
        }
      } catch (e) {
        print('Error loading user role: $e');
        userRole.value = 'User';
      }
    } else {
      userRole.value = '';
    }
  }

  Future<bool> register({
    required String email, 
    required String password, 
    required String role
  }) async {
    isLoading.value = true;
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Sign outta immediately after registration
      await _auth.signOut();
      userRole.value = '';
      user.value = null; // Ensure user is reset
      
      Get.snackbar(
        'Success', 
        'Registration successful! Please sign in.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
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
      Get.snackbar(
        'Registration Error', 
        message, 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Registration failed. Please try again.', 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // Wait for user role to be loaded
      await _waitForRoleLoad();
      
      // Navigate to appropriate screen based on role
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isAdmin()) {
          Get.offAllNamed('/admin');
        } else {
          Get.offAllNamed('/user');
        }
      });
      
      Get.snackbar(
        'Success', 
        'Login successful!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
      
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'An unknown error occurred.';
      }
      Get.snackbar(
        'Login Error', 
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Login failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _waitForRoleLoad() async {
    int attempts = 0;
    const maxAttempts = 50; // Maximum 5 seconds wait
    
    while (userRole.value.isEmpty && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    // If role is still empty after waiting, try to load it manually
    if (userRole.value.isEmpty && user.value != null) {
      await _loadUserRole(user.value);
    }
    
    // If still empty, set default
    if (userRole.value.isEmpty) {
      userRole.value = 'User';
    }
  }

  Future<void> logout() async {
    try {
      print('Starting logout process...');
      await _auth.signOut();
      print('Firebase sign out successful');
      userRole.value = '';
      user.value = null; // Ensure user is reset
      print('User role and user reset');
      
      // Navigate to login screen
      Get.offAllNamed('/login');
      print('Navigated to login screen');
      
      Get.snackbar(
        'Success', 
        'Logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar(
        'Error', 
        'Failed to logout: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool isAdmin() {
    return userRole.value == 'Admin';
  }

  bool isUser() {
    return userRole.value == 'User';
  }

  String getCurrentRole() {
    return userRole.value.isEmpty ? 'User' : userRole.value;
  }

  bool isLoggedIn() {
    return user.value != null;
  }

  String? getUserEmail() {
    return user.value?.email;
  }

  String? getUserId() {
    return user.value?.uid;
  }
}