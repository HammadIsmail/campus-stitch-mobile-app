import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/state/auth_state.dart';
import '../core/theme/app_theme.dart';

class ReviewModal extends StatefulWidget {
  final String targetUserId;
  final String targetName;
  final String category; // 'commute', 'marketplace', 'services'

  const ReviewModal({
    super.key,
    required this.targetUserId,
    required this.targetName,
    required this.category,
  });

  static void show(
    BuildContext context, {
    required String targetUserId,
    required String targetName,
    required String category,
    VoidCallback? onReviewSubmitted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ReviewModal(
          targetUserId: targetUserId,
          targetName: targetName,
          category: category,
        ),
      ),
    ).then((submitted) {
      if (submitted == true && onReviewSubmitted != null) {
        onReviewSubmitted();
      }
    });
  }

  @override
  State<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  int _selectedRating = 5;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = AuthState.instance.user;
    final raterId = user?.userId ?? '';

    if (raterId.isNotEmpty && raterId == widget.targetUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot submit a review for yourself.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await ApiClient.post(
        '${ApiConstants.baseUrl}/api/profile/ratings',
        body: {
          'userId': widget.targetUserId,
          'raterId': raterId.isNotEmpty ? raterId : 'u_${user?.name.toLowerCase().replaceAll(' ', '_') ?? 'student'}',
          'raterName': user?.name ?? 'Verified Peer',
          'raterStudentId': user?.studentId ?? 'STUDENT',
          'rating': _selectedRating,
          'category': widget.category,
          'comment': _commentCtrl.text.trim().isNotEmpty
              ? _commentCtrl.text.trim()
              : 'Great campus experience with ${widget.targetName}.',
        },
      );

      if (!mounted) return;

      if (res.success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted! Thank you for rating.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'Failed to submit review. You may have already reviewed this peer.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.zinc700 : AppColors.zinc300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Rate Experience with ${widget.targetName}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Share feedback to help the university community maintain a trusted marketplace and commute network.',
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.zinc400 : AppColors.zinc500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 5-Star Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNum = index + 1;
              final isFilled = starNum <= _selectedRating;
              return IconButton(
                iconSize: 36,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onPressed: () => setState(() => _selectedRating = starNum),
                icon: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFilled ? const Color(0xFFF59E0B) : (isDark ? AppColors.zinc700 : AppColors.zinc300),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Written Feedback (Optional)',
              hintText: 'Punctuality, condition of item, friendly communication...',
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            child: _isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
