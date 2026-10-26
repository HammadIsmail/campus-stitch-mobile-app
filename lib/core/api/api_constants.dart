import 'package:flutter/foundation.dart';

class ApiConstants {
  static String? _customBaseUrl;

  // Development: Use local Next.js server (http://localhost:3000) when running Flutter Web locally
  // Production: Use live Vercel deployment (https://campus-stitch.vercel.app)
  static String get baseUrl =>
      _customBaseUrl ??
      ((kIsWeb && kDebugMode)
          ? 'http://localhost:3000'
          : 'https://campus-stitch.vercel.app');

  static set baseUrl(String url) => _customBaseUrl = url;

  // Auth Endpoints
  static String get signIn => '$baseUrl/api/auth/sign-in';
  static String get signUp => '$baseUrl/api/auth/sign-up';
  static String get checkEmail => '$baseUrl/api/auth/check-email';
  static String get sendOtp => '$baseUrl/api/auth/otp/send';
  static String get forgotPassword => '$baseUrl/api/auth/forgot-password';
  static String get resetPassword => '$baseUrl/api/auth/reset-password';
  static String get me => '$baseUrl/api/auth/me';

  // Tenant Endpoints
  static String get universities => '$baseUrl/api/universities';
  static String get campuses => '$baseUrl/api/campuses';

  // Campus Admin Verification Endpoint
  static String get verifications => '$baseUrl/api/verifications';

  // Domain Feature Endpoints
  static String get communityPosts => '$baseUrl/api/community/posts';
  static String get communityVote => '$baseUrl/api/community/posts/vote';
  static String get communityList => '$baseUrl/api/community/list';
  static String get communityJoin => '$baseUrl/api/community/join';
  static String get communityComments => '$baseUrl/api/community/comments';

  // Push Notifications
  static String get pushToken => '$baseUrl/api/notifications/token';

  // Profile & Account Deletion
  static String get profile => '$baseUrl/api/profile';

  // Commute & Rides Endpoints
  static String get commuteRides => '$baseUrl/api/commute/rides';
  static String get commuteBook => '$baseUrl/api/commute/book';
  static String get commuteBikes => '$baseUrl/api/commute/bikes';

  // Marketplace Endpoints
  static String get marketListings => '$baseUrl/api/market';

  // Campus Services Endpoints
  static String get campusServices => '$baseUrl/api/services';
  static String get hostelServices => campusServices;

  // Image & File Upload
  static String get upload => '$baseUrl/api/upload';

  // In-App Self-Update
  static String get appVersion => '$baseUrl/api/app/version';
}


