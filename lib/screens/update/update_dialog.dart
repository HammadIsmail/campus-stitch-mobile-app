import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_version_model.dart';
import '../../services/app_update_service.dart';

class UpdateDialog extends StatelessWidget {
  final AppVersionModel versionInfo;
  final bool isForce;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
    this.isForce = false,
  });

  static Future<void> show(
    BuildContext context, {
    required AppVersionModel versionInfo,
    bool isForce = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: !isForce,
      builder: (_) => UpdateDialog(versionInfo: versionInfo, isForce: isForce),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !isForce,
      child: Dialog(
        backgroundColor: isDark ? const Color(0xFF121215) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Icon & Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white : AppColors.black,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.system_update_rounded,
                        color: isDark ? AppColors.black : AppColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isForce
                          ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                          : (isDark ? const Color(0xFF18181B) : const Color(0xFFE4E4E7)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isForce ? 'Mandatory' : 'Optional',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isForce
                            ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
                            : AppColors.zinc500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                versionInfo.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 6),

              // Version string
              Text(
                'v${AppConfig.currentVersion} ➔ v${versionInfo.latestVersion} (${versionInfo.fileSize})',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppColors.zinc500,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              // Release Notes box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  versionInfo.releaseNotes.trim(),
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: isDark ? AppColors.zinc300 : AppColors.zinc700,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  if (!isForce) ...[
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? AppColors.zinc800 : AppColors.zinc300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Later',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: isForce ? 1 : 2,
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          AppUpdateService.launchDownloadUrl(versionInfo.apkDownloadUrl);
                          if (!isForce) {
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.white : AppColors.black,
                          foregroundColor: isDark ? AppColors.black : AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_rounded, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Update APK',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
