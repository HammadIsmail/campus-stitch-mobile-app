import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_version_model.dart';
import '../../services/app_update_service.dart';

class UpdateScreen extends StatefulWidget {
  final AppVersionModel versionInfo;
  final bool isForce;
  final VoidCallback? onDismiss;

  const UpdateScreen({
    super.key,
    required this.versionInfo,
    this.isForce = false,
    this.onDismiss,
  });

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _isDownloading = false;

  Future<void> _handleUpdate() async {
    setState(() => _isDownloading = true);
    final success = await AppUpdateService.launchDownloadUrl(widget.versionInfo.apkDownloadUrl);
    if (!mounted) return;
    setState(() => _isDownloading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open download link. Please check your network connection.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !widget.isForce,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.isForce) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please update CampuStitch to continue.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF09090B) : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Squircle Icon
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white : AppColors.black,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'CS',
                        style: TextStyle(
                          color: isDark ? AppColors.black : AppColors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mandatory / Optional Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.isForce
                          ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                          : (isDark ? const Color(0xFF18181B) : const Color(0xFFE4E4E7)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.isForce
                            ? (isDark ? const Color(0xFFB45309) : const Color(0xFFF59E0B))
                            : (isDark ? AppColors.zinc800 : AppColors.zinc300),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isForce ? Icons.warning_amber_rounded : Icons.rocket_launch_rounded,
                          size: 14,
                          color: widget.isForce
                              ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
                              : (isDark ? AppColors.zinc300 : AppColors.zinc700),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isForce ? 'MANDATORY UPDATE' : 'NEW RELEASE AVAILABLE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: widget.isForce
                                ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
                                : (isDark ? AppColors.zinc300 : AppColors.zinc700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Headline
                  Text(
                    widget.versionInfo.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Version Transition Pill (Installed -> New)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121215) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'v${AppConfig.currentVersion}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.zinc500,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.zinc500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.white : AppColors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'v${widget.versionInfo.latestVersion}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.black : AppColors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${widget.versionInfo.fileSize})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.zinc500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Release Notes Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121215) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 15,
                              color: isDark ? Colors.amber[400] : Colors.amber[700],
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'What\'s New in this Release',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.versionInfo.releaseNotes.trim(),
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: isDark ? AppColors.zinc300 : AppColors.zinc700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Primary Download CTA
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isDownloading ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.white : AppColors.black,
                        foregroundColor: isDark ? AppColors.black : AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isDownloading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: isDark ? AppColors.black : AppColors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Download & Install Update',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // Optional Skip / Later Button
                  if (!widget.isForce) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () {
                          if (widget.onDismiss != null) {
                            widget.onDismiss!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.zinc500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (widget.isForce) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'This update includes critical security and protocol changes required to access campus services.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.zinc500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
