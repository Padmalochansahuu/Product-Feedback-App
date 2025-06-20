import 'package:feedback_app/admin_screen.dart';
import 'package:feedback_app/auth_service.dart';
import 'package:feedback_app/feedback_controller.dart';
import 'package:feedback_app/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(AuthService());
  Get.put(AppController());
  await Get.find<AuthService>().setupPredefinedUsers();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Product Feedback App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Root(),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  final String adminEmail = 'admin@gmail.com';

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find();

    return Obx(() {
      if (controller.user.value == null) {
        return const LoginPage();
      } else if (controller.user.value!.email == adminEmail) {
        return const AdminScreen();
      } else {
        return const UserFeedbackScreen();
      }
    });
  }
}