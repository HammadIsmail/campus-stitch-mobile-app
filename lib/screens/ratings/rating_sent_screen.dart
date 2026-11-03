import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_button.dart';

class RatingSentScreen extends StatelessWidget {
  final String peerName;
  final int rating;
  final List<String> tags;

  const RatingSentScreen({
    super.key,
    required this.peerName,
    required this.rating,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Big Checkmark in primary soft circle
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.check,
                        size: 44,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Thanks for rating $peerName',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final isFilled = (index + 1) <= rating;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(
                            LucideIcons.star,
                            size: 28,
                            color: isFilled ? colors.amberAccent : colors.border,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    if (tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.primarySoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textOnSoft,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Description
                    Text(
                      'Your rating helps other students on your campus. You can change it for the next 24 hours.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: colors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Column(
                children: [
                  AppButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    text: 'Edit my rating',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
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
