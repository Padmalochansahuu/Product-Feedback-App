// Updated AuthWrapper in main.dart
import 'package:feedback_app/core/screens/admin/admin_screen.dart';
import 'package:feedback_app/core/screens/user/login_screen.dart';
import 'package:feedback_app/core/screens/user/user_feedback_screen.dart';
import 'package:feedback_app/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AuthService>(
      builder: (controller) {
        // If user is not logged in, show login page
        if (controller.user.value == null) {
          return const LoginPage();
        }
        
        // If user is logged in but role is still loading, show loading screen
        if (controller.userRole.value.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.isAdmin()) {
            if (Get.currentRoute != '/admin') {
              Get.offAllNamed('/admin');
            }
          } else {
            if (Get.currentRoute != '/user') {
              Get.offAllNamed('/user');
            }
          }
        });
        
        // Return appropriate screen based on role
        if (controller.isAdmin()) {
          return const AdminScreen();
        } else {
          return const UserFeedbackScreen();
        }
      },
    );
  }
}