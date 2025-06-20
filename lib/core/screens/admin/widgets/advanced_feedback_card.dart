import 'dart:io';
import 'package:feedback_app/core/constants/app_theme.dart';
import 'package:feedback_app/core/models/feedback_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdvancedFeedbackCard extends StatefulWidget {
  final FeedbackModel feedback;

  const AdvancedFeedbackCard({super.key, required this.feedback});

  @override
  State<AdvancedFeedbackCard> createState() => _AdvancedFeedbackCardState();
}

class _AdvancedFeedbackCardState extends State<AdvancedFeedbackCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Color _getRatingColor(double rating) {
    final int intRating = rating.floor();
    switch (intRating) {
      case 5:
        return const Color(0xFF10B981);
      case 4:
        return const Color(0xFF059669);
      case 3:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFFEF4444);
      case 1:
        return const Color(0xFFDC2626);
      default:
        return AppTheme.textLight;
    }
  }

  String _getRatingText(double rating) {
    final int intRating = rating.floor();
    switch (intRating) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Very Good';
      case 3:
        return 'Good';
      case 2:
        return 'Fair';
      case 1:
        return 'Poor';
      default:
        return 'Unknown';
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      return DateFormat('dd MMM yyyy').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: AppTheme.largeRadius,
              shadowColor: AppTheme.primaryColor.withOpacity(0.1),
              child: InkWell(
                borderRadius: AppTheme.largeRadius,
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                onHover: (isHovering) {
                  if (isHovering) {
                    _hoverController.forward();
                  } else {
                    _hoverController.reverse();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFFAFAFA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppTheme.largeRadius,
                    border: Border.all(
                      color: _getRatingColor(widget.feedback.rating).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getRatingColor(widget.feedback.rating),
                                        _getRatingColor(widget.feedback.rating).withOpacity(0.7),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.feedback.userEmail[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.feedback.userEmail,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _getTimeAgo(widget.feedback.timestamp),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getRatingColor(widget.feedback.rating),
                                    borderRadius: AppTheme.smallRadius,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getRatingColor(widget.feedback.rating).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.feedback.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      index < widget.feedback.rating.floor()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: index < widget.feedback.rating.floor()
                                          ? _getRatingColor(widget.feedback.rating)
                                          : AppTheme.textLight,
                                      size: 20,
                                    ),
                                  );
                                }),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getRatingColor(widget.feedback.rating).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getRatingText(widget.feedback.rating),
                                    style: TextStyle(
                                      color: _getRatingColor(widget.feedback.rating),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.feedback.comment,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                    color: AppTheme.textPrimary,
                                  ),
                              maxLines: _isExpanded ? null : 3,
                              overflow: _isExpanded ? null : TextOverflow.ellipsis,
                            ),
                            if (widget.feedback.comment.length > 150)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _isExpanded ? 'Show less' : 'Read more',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.feedback.imagePath != null)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: ClipRRect(
                            borderRadius: AppTheme.mediumRadius,
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200, width: 1),
                                borderRadius: AppTheme.mediumRadius,
                              ),
                              child: Image.file(
                                File(widget.feedback.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Image not found',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}