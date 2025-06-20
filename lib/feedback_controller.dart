import 'dart:convert';
import 'dart:io';
import 'package:feedback_app/auth_service.dart';
import 'package:feedback_app/feedback_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class AppController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final Rx<User?> user = Rx<User?>(null);
  final RxList<FeedbackModel> feedbackList = <FeedbackModel>[].obs;
  final isLoading = false.obs;
  final Rx<File?> pickedImage = Rx<File?>(null);
  final totalReviews = 0.obs;
  final averageRating = 0.0.obs;
  final highRatingsPercentage = 0.0.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, _handleUserChanged);
    _loadAnalyticsFromCache();
    _loadFeedbackFromCache();
  }

  void _handleUserChanged(User? currentUser) {
    if (currentUser == null) {
      feedbackList.clear();
      _clearAnalytics();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await Get.find<AuthService>().login(email, password);
      await _loadFeedbackFromCache();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await Get.find<AuthService>().logout();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'feedback_${DateTime.now().toIso8601String()}.jpg';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await image.readAsBytes());
      pickedImage.value = file;
    }
  }

  Future<void> submitFeedback({required double rating, required String comment}) async {
    if (user.value == null) {
      Get.snackbar('Error', 'You must be logged in to submit feedback.');
      return;
    }
    isLoading.value = true;
    try {
      String? imagePath;
      if (pickedImage.value != null) {
        imagePath = pickedImage.value!.path;
      }

      final feedback = FeedbackModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.value!.uid,
        userEmail: user.value!.email!,
        rating: rating,
        comment: comment,
        imagePath: imagePath,
        timestamp: DateTime.now(),
      );
      feedbackList.add(feedback);
      await _saveFeedbackToCache(feedback);
      _calculateAnalytics(feedbackList);
      Get.snackbar('Success', 'Feedback submitted successfully!');
      pickedImage.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit feedback: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateAnalytics(List<FeedbackModel> list) {
    if (list.isEmpty) {
      _clearAnalytics();
      return;
    }
    totalReviews.value = list.length;
    averageRating.value = list.map((f) => f.rating).reduce((a, b) => a + b) / list.length;
    final highRatings = list.where((f) => f.rating >= 4).length;
    highRatingsPercentage.value = (highRatings / list.length) * 100;
    _saveAnalyticsToCache();
  }

  RxList<FeedbackModel> get filteredFeedbackList {
    if (searchQuery.value.isEmpty) {
      return feedbackList;
    }
    return feedbackList
        .where((feedback) =>
            feedback.comment.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            feedback.userEmail.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList()
        .obs;
  }

  Future<void> _saveAnalyticsToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalReviews', totalReviews.value);
    await prefs.setDouble('averageRating', averageRating.value);
    await prefs.setDouble('highRatingsPercentage', highRatingsPercentage.value);
  }

  Future<void> _loadAnalyticsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    totalReviews.value = prefs.getInt('totalReviews') ?? 0;
    averageRating.value = prefs.getDouble('averageRating') ?? 0.0;
    highRatingsPercentage.value = prefs.getDouble('highRatingsPercentage') ?? 0.0;
  }

  Future<void> _saveFeedbackToCache(FeedbackModel feedback) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cachedFeedback = prefs.getStringList('feedback') ?? [];
    cachedFeedback.add(jsonEncode(feedback.toJson()));
    await prefs.setStringList('feedback', cachedFeedback);
  }

  Future<void> _loadFeedbackFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cachedFeedback = prefs.getStringList('feedback') ?? [];
    feedbackList.assignAll(cachedFeedback.map((f) {
      final data = jsonDecode(f);
      return FeedbackModel.fromJson(data);
    }).toList());
    _calculateAnalytics(feedbackList);
  }

  void _clearAnalytics() {
    totalReviews.value = 0;
    averageRating.value = 0.0;
    highRatingsPercentage.value = 0.0;
    _saveAnalyticsToCache();
  }

  Future<List<Map<String, dynamic>>> getTopFeedbackUsersLast30Days() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final filteredFeedback = feedbackList.where((f) => f.timestamp.isAfter(thirtyDaysAgo)).toList();

    if (filteredFeedback.isEmpty) {
      return [];
    }

    final Map<String, int> userFeedbackCounts = {};
    for (var feedback in filteredFeedback) {
      userFeedbackCounts[feedback.userId] = (userFeedbackCounts[feedback.userId] ?? 0) + 1;
    }

    final sortedUsers = userFeedbackCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedUsers
        .take(3)
        .map((entry) => {'userId': entry.key, 'count': entry.value})
        .toList();
  }

  Map<int, int> getRatingDistribution() {
    final Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var feedback in feedbackList) {
      // Ensure rating is treated as double and floor it to get the integer part
      final rating = feedback.rating.floor();
      if (distribution.containsKey(rating)) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
    }
    return distribution;
  }
}