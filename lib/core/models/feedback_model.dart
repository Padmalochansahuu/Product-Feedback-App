class FeedbackModel {
  final String id;
  final String userId;
  final String userEmail;
  final double rating;
  final String comment;
  final String? imagePath;
  final DateTime timestamp;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.rating,
    required this.comment,
    this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'rating': rating,
      'comment': comment,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> data) {
    return FeedbackModel(
      id: data['id'],
      userId: data['userId'],
      userEmail: data['userEmail'],
      rating: data['rating'].toDouble(),
      comment: data['comment'],
      imagePath: data['imagePath'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }
}