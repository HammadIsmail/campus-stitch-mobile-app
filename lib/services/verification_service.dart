import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/verification_model.dart';

class VerificationService {
  static Future<List<VerificationModel>> getVerifications({String? campusId}) async {
    String url = ApiConstants.verifications;
    if (campusId != null && campusId.isNotEmpty && campusId != 'all') {
      url += '?campusId=$campusId';
    }
    final res = await ApiClient.get(url);
    if (res.success && res.data is Map) {
      final list = (res.data as Map)['verifications'];
      if (list is List) {
        return list.map((item) => VerificationModel.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    }
    return [];
  }

  static Future<ApiResponse> reviewVerification({
    required String verificationId,
    required String action, // 'approved' | 'rejected'
    String? rejectionReason,
  }) async {
    return await ApiClient.patch(
      ApiConstants.verifications,
      body: {
        'verificationId': verificationId,
        'action': action,
        'rejectionReason': rejectionReason ?? '',
      },
    );
  }

  static Future<ApiResponse> submitVerification({
    required String name,
    required String studentId,
    required String email,
    required String university,
    required String campusId,
    required String campusName,
    required String cardPhotoUrl,
    required String livePhotoUrl,
    String? program,
    String? department,
  }) async {
    return await ApiClient.post(
      ApiConstants.verifications,
      body: {
        'name': name.trim(),
        'studentId': studentId.trim(),
        'email': email.trim(),
        'university': university,
        'campusId': campusId,
        'campusName': campusName,
        'city': campusName,
        'cardPhotoUrl': cardPhotoUrl,
        'livePhotoUrl': livePhotoUrl,
        'program': program ?? 'BS Computer Science',
        'department': department ?? 'Computer Science',
      },
    );
  }
}
