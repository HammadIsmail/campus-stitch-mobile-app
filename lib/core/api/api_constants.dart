class ApiConstants {
  // Production live Next.js backend on Vercel
  static String baseUrl = 'https://campus-stitch.vercel.app';

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

  // Push Notifications
  static String get pushToken => '$baseUrl/api/notifications/token';
}
