import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/tenant_model.dart';

class TenantService {
  static Future<List<University>> getUniversities() async {
    final res = await ApiClient.get(ApiConstants.universities);
    if (res.success && res.data is Map) {
      final list = (res.data as Map)['universities'];
      if (list is List) {
        return list.map((item) => University.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    }
    return [];
  }

  static Future<List<Campus>> getCampuses({String? universityId}) async {
    String url = ApiConstants.campuses;
    if (universityId != null && universityId.isNotEmpty) {
      url += '?universityId=$universityId';
    }
    final res = await ApiClient.get(url);
    if (res.success && res.data is Map) {
      final list = (res.data as Map)['campuses'];
      if (list is List) {
        return list.map((item) => Campus.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    }
    return [];
  }
}
