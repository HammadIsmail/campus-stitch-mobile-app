import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/storage/session_store.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<ApiResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.signIn,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password.trim(),
      },
    );

    if (response.success && response.data is Map) {
      final data = response.data as Map;
      final token = data['token']?.toString() ?? '';
      if (data['user'] != null && data['user'] is Map) {
        final user = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
        await SessionStore.saveSession(token: token, user: user);
      }
    }

    return response;
  }

  static Future<ApiResponse> checkEmail(String email) async {
    return await ApiClient.post(
      ApiConstants.checkEmail,
      body: {'email': email.trim().toLowerCase()},
    );
  }

  static Future<ApiResponse> sendOtp(String email) async {
    return await ApiClient.post(
      ApiConstants.sendOtp,
      body: {'email': email.trim().toLowerCase()},
    );
  }

  static Future<ApiResponse> forgotPassword(String email) async {
    return await ApiClient.post(
      ApiConstants.forgotPassword,
      body: {'email': email.trim().toLowerCase()},
    );
  }

  static Future<ApiResponse> signUp({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String universityId,
    required String universityName,
    required String campusId,
    required String campusName,
    String? program,
    String? code,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.signUp,
      body: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password.trim(),
        'studentId': studentId.trim().toUpperCase(),
        'universityId': universityId,
        'university': universityName,
        'campusId': campusId,
        'campusName': campusName,
        'city': campusName,
        'program': program ?? 'BS Computer Science',
        if (code != null && code.isNotEmpty) 'code': code.trim(),
      },
    );

    if (response.success && response.data is Map) {
      final data = response.data as Map;
      final token = data['token']?.toString() ?? '';
      if (data['user'] != null && data['user'] is Map) {
        final user = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
        await SessionStore.saveSession(token: token, user: user);
      }
    }

    return response;
  }

  static Future<UserModel?> checkCurrentSession() async {
    final session = await SessionStore.loadSession();
    if (session == null) return null;

    final cachedUser = session['user'] as UserModel?;

    // Try refreshing from /api/auth/me
    try {
      final res = await ApiClient.get(ApiConstants.me);
      if (res.success && res.data is Map) {
        final data = res.data as Map;
        if (data['authenticated'] == true && data['user'] != null) {
          final user = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
          final token = session['token']?.toString() ?? '';
          await SessionStore.saveSession(token: token, user: user);
          return user;
        }
      }
    } catch (_) {}

    return cachedUser;
  }

  static Future<void> signOut() async {
    await SessionStore.clearSession();
  }

  static Future<ApiResponse> deleteAccount({String? userId, String? email}) async {
    final response = await ApiClient.delete(
      ApiConstants.profile,
      body: {
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );
    await SessionStore.clearSession();
    return response;
  }
}
