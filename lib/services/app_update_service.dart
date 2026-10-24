import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../core/api/api_constants.dart';
import '../core/config/app_config.dart';
import '../models/app_version_model.dart';

class UpdateCheckResult {
  final bool hasUpdate;
  final bool isForceUpdate;
  final AppVersionModel? versionInfo;

  const UpdateCheckResult({
    required this.hasUpdate,
    required this.isForceUpdate,
    this.versionInfo,
  });
}

class AppUpdateService {
  /// Fetch version metadata from Next.js backend and evaluate against local installed version
  static Future<UpdateCheckResult> checkForUpdate() async {
    try {
      final uri = Uri.parse(ApiConstants.appVersion);
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint('[AppUpdateService] Server returned status ${response.statusCode}');
        return const UpdateCheckResult(hasUpdate: false, isForceUpdate: false);
      }

      final data = jsonDecode(response.body);
      if (data['success'] != true || data['version'] == null) {
        return const UpdateCheckResult(hasUpdate: false, isForceUpdate: false);
      }

      final serverVersion = AppVersionModel.fromJson(data['version']);

      // 1. Evaluate whether a new build/version is available
      final bool hasNewerBuild = serverVersion.buildNumber > AppConfig.currentBuildNumber;
      final bool hasNewerSemver = _compareSemver(serverVersion.latestVersion, AppConfig.currentVersion) > 0;
      final bool hasUpdate = hasNewerBuild || hasNewerSemver;

      if (!hasUpdate) {
        return UpdateCheckResult(
          hasUpdate: false,
          isForceUpdate: false,
          versionInfo: serverVersion,
        );
      }

      // 2. Evaluate whether this is a mandatory/blocking update
      final bool isBelowMinBuild = AppConfig.currentBuildNumber < serverVersion.minSupportedBuild;
      final bool isBelowMinSemver = _compareSemver(AppConfig.currentVersion, serverVersion.minSupportedVersion) < 0;
      final bool isForceUpdate = serverVersion.forceUpdate || isBelowMinBuild || isBelowMinSemver;

      debugPrint(
        '[AppUpdateService] Update detected: v${AppConfig.currentVersion}(b${AppConfig.currentBuildNumber}) '
        '-> v${serverVersion.latestVersion}(b${serverVersion.buildNumber}) | Force: $isForceUpdate',
      );

      return UpdateCheckResult(
        hasUpdate: true,
        isForceUpdate: isForceUpdate,
        versionInfo: serverVersion,
      );
    } catch (e) {
      debugPrint('[AppUpdateService] Failed to check for update: $e');
      return const UpdateCheckResult(hasUpdate: false, isForceUpdate: false);
    }
  }

  /// Launch APK direct download link in external Android browser or download manager
  static Future<bool> launchDownloadUrl(String url) async {
    try {
      if (url.trim().isEmpty) return false;
      final uri = Uri.parse(url.trim());
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[AppUpdateService] Failed to launch download URL: $e');
      return false;
    }
  }

  /// Helper: Compare semver strings (returns > 0 if v1 > v2, < 0 if v1 < v2, 0 if equal)
  static int _compareSemver(String v1, String v2) {
    try {
      final parts1 = v1.split('.').map((p) => int.tryParse(p) ?? 0).toList();
      final parts2 = v2.split('.').map((p) => int.tryParse(p) ?? 0).toList();

      while (parts1.length < 3) {
        parts1.add(0);
      }
      while (parts2.length < 3) {
        parts2.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (parts1[i] > parts2[i]) return 1;
        if (parts1[i] < parts2[i]) return -1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
