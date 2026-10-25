import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

class VerificationService {

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
