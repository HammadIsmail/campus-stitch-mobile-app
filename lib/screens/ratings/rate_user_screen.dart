import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/storage/session_store.dart';
import '../../core/theme/app_theme.dart';
import '../../services/rating_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/avatar_circle.dart';
import '../../widgets/sub_header.dart';
import 'rating_sent_screen.dart';

class RateUserScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String contextTitle;
  final String? transactionId;
  final String? category;

  const RateUserScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.contextTitle,
    this.transactionId,
    this.category,
  });

  @override
  State<RateUserScreen> createState() => _RateUserScreenState();
}

class _RateUserScreenState extends State<RateUserScreen> {
  int _selectedRating = 4;
  final Set<String> _selectedTags = {'On time', 'Honest'};
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    'On time',
    'Honest',
    'Polite',
    'Bike in good condition',
    'Late',
    'Not as described',
  ];

  final Map<int, String> _ratingLabels = {
    1: 'Poor',
    2: 'Fair',
    3: 'Average',
    4: 'Good',
    5: 'Excellent',
  };

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    final user = await SessionStore.getUser();
    final campusId = user?.campusId ?? 'camp_fast_isb';

    final result = await RatingService.submitRating(
      userId: widget.peerId,
      rating: _selectedRating,
      tags: _selectedTags.toList(),
      comment: _commentController.text,
      transactionId: widget.transactionId,
      category: widget.category ?? 'general',
      campusId: campusId,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RatingSentScreen(
              peerName: widget.peerName,
              rating: _selectedRating,
              tags: _selectedTags.toList(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Could not submit rating'),
            backgroundColor: context.colors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Rate your experience',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Peer summary card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          AvatarCircle(
                            name: widget.peerName,
                            size: 48,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.peerName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.contextTitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Star Rating selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNumber = index + 1;
                        final isSelected = starNumber <= _selectedRating;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedRating = starNumber),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              LucideIcons.star,
                              size: 40,
                              color: isSelected ? colors.amberAccent : colors.border,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _ratingLabels[_selectedRating] ?? 'Good',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // What went well tags
                    Text(
                      'What went well?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () => _toggleTag(tag),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? colors.primary : colors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected ? colors.primary : colors.inputBorder,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? Colors.white : colors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Short review textarea
                    Text(
                      'Write a short review (optional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 96,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.inputBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: TextField(
                        controller: _commentController,
                        maxLines: null,
                        style: TextStyle(fontSize: 14, color: colors.textPrimary),
                        decoration: AppTheme.borderlessInput(
                          hintText: 'Tell other students what it was like',
                          hintStyle: TextStyle(fontSize: 14, color: colors.textMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit footer
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Column(
                children: [
                  Text(
                    'Your rating is visible to students on your campus.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    text: 'Submit rating',
                    isLoading: _isSubmitting,
                    onPressed: _submitRating,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
