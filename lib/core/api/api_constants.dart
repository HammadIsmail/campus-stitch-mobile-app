import 'package:flutter/foundation.dart';

class ApiConstants {
  // Default development URLs:
  // - Android Emulator: http://10.0.2.2:3000
  // - iOS Simulator / macOS / Windows / Web: http://localhost:3000
  // - Physical Device: Set to your LAN IP (e.g. http://192.168.1.10:3000)
  static String baseUrl = defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:3000'
      : 'http://localhost:3000';

  // Auth Endpoints
  static String get signIn => '$baseUrl/api/auth/sign-in';
  static String get signUp => '$baseUrl/api/auth/sign-up';
  static String get me => '$baseUrl/api/auth/me';

  // Tenant Endpoints
  static String get universities => '$baseUrl/api/universities';
  static String get campuses => '$baseUrl/api/campuses';

  // Campus Admin KYC Endpoint
  static String get verifications => '$baseUrl/api/verifications';

  // Domain Feature Endpoints
  static String get communityPosts => '$baseUrl/api/community/posts';
  static String get communityVote => '$baseUrl/api/community/posts/vote';
}
