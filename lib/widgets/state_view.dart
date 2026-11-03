import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';

enum _StateViewKind { loadingList, loadingGrid, message }

class StateView extends StatefulWidget {
  final _StateViewKind _kind;
  final int count;
  final IconData? icon;
  final String? title;
  final String? body;
  final String? ctaText;
  final VoidCallback? onCta;
  final String? secondaryText;
  final VoidCallback? onSecondary;
  final bool isWarm;

  const StateView._({
    super.key,
    required this._kind,
    this.icon,
    this.title,
    this.body,
    this.ctaText,
    this.onCta,
    this.secondaryText,
    this.onSecondary,
    this.isWarm = false,
  }) : count = 4;

  const StateView.loadingList({super.key, this.count = 4})
      : _kind = _StateViewKind.loadingList,
        icon = null,
        title = null,
        body = null,
        ctaText = null,
        onCta = null,
        secondaryText = null,
        onSecondary = null,
        isWarm = false;

  const StateView.loadingGrid({super.key, this.count = 4})
      : _kind = _StateViewKind.loadingGrid,
        icon = null,
        title = null,
        body = null,
        ctaText = null,
        onCta = null,
        secondaryText = null,
        onSecondary = null,
        isWarm = false;

  factory StateView.empty({
    Key? key,
    IconData icon = LucideIcons.inbox,
    required String title,
    required String body,
    String? ctaText,
    String? actionLabel,
    VoidCallback? onCta,
    VoidCallback? onAction,
    String? secondaryText,
    VoidCallback? onSecondary,
  }) {
    return StateView._(
      key: key,
      kind: _StateViewKind.message,
      icon: icon,
      title: title,
      body: body,
      ctaText: actionLabel ?? ctaText,
      onCta: onAction ?? onCta,
      secondaryText: secondaryText,
      onSecondary: onSecondary,
      isWarm: false,
    );
  }

  factory StateView.offline({
    Key? key,
    VoidCallback? onRetry,
    VoidCallback? onAction,
    VoidCallback? onSavedItems,
  }) {
    return StateView._(
      key: key,
      kind: _StateViewKind.message,
      icon: LucideIcons.wifiOff,
      title: AppStrings.noInternetTitle,
      body: AppStrings.noInternetBody,
      ctaText: AppStrings.tryAgain,
      onCta: onAction ?? onRetry,
      secondaryText: onSavedItems != null ? AppStrings.viewSavedItems : null,
      onSecondary: onSavedItems,
      isWarm: true,
    );
  }

  factory StateView.error({
    Key? key,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onAction,
  }) {
    return StateView._(
      key: key,
      kind: _StateViewKind.message,
      icon: LucideIcons.triangleAlert,
      title: 'Unable to Load',
      body: message,
      ctaText: (onAction ?? onRetry) != null ? AppStrings.tryAgain : null,
      onCta: onAction ?? onRetry,
      isWarm: true,
    );
  }

  @override
  State<StateView> createState() => _StateViewState();
}

class _StateViewState extends State<StateView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget._kind) {
      case _StateViewKind.loadingList:
        return _buildLoadingList();
      case _StateViewKind.loadingGrid:
        return _buildLoadingGrid();
      case _StateViewKind.message:
        return _buildMessage(context);
    }
  }

  Widget _buildLoadingList() {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        final opacity = _pulseAnimation.value;

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.count,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.skeleton,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonBar(colors.skeleton, widthFactor: 0.70, height: 14, opacity: opacity),
                        const SizedBox(height: 8),
                        _buildSkeletonBar(colors.skeleton, widthFactor: 0.50, height: 12, opacity: opacity),
                        const SizedBox(height: 8),
                        _buildSkeletonBar(colors.skeleton, widthFactor: 0.88, height: 12, opacity: opacity),
                        const SizedBox(height: 12),
                        _buildSkeletonBar(colors.skeleton, widthFactor: 0.42, height: 36, opacity: opacity),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        final opacity = _pulseAnimation.value;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: widget.count,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: opacity,
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.skeleton,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSkeletonBar(colors.skeleton, widthFactor: 0.80, height: 14, opacity: opacity),
                  const SizedBox(height: 8),
                  _buildSkeletonBar(colors.skeleton, widthFactor: 0.45, height: 14, opacity: opacity),
                  const SizedBox(height: 8),
                  _buildSkeletonBar(colors.skeleton, widthFactor: 0.65, height: 12, opacity: opacity),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonBar(Color color, {required double widthFactor, required double height, required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height > 20 ? 12 : 6),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    final colors = context.colors;

    final iconBg = widget.isWarm ? colors.amberSoft : colors.primarySoft;
    final iconFg = widget.isWarm ? colors.textOnAmberSoft : colors.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon ?? LucideIcons.search,
                size: 40,
                color: iconFg,
              ),
            ),
            const SizedBox(height: 20),

            if (widget.title != null)
              Text(
                widget.title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.01 * 21,
                  height: 1.2,
                  color: colors.text,
                ),
              ),

            const SizedBox(height: 8),

            if (widget.body != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: Text(
                  widget.body!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    height: 1.5,
                    color: colors.mutedText,
                  ),
                ),
              ),

            if (widget.ctaText != null && widget.onCta != null) ...[
              const SizedBox(height: 22),
              GestureDetector(
                onTap: widget.onCta,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.ctaText!,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],

            if (widget.secondaryText != null && widget.onSecondary != null) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: widget.onSecondary,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: AppDimensions.minTouchTarget,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Text(
                    widget.secondaryText!,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
