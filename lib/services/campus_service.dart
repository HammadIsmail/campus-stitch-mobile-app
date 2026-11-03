import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/service_model.dart';

class CampusService {
  // Student Campus Services
  static Future<List<CampusServiceModel>> getServices({String? campusId, String? category}) async {
    try {
      final queryParams = <String>[];
      if (campusId != null && campusId.isNotEmpty) {
        queryParams.add('campusId=$campusId');
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams.add('category=${Uri.encodeComponent(category)}');
      }
      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final res = await ApiClient.get('${ApiConstants.campusServices}$queryString');
      if (res.success && res.data is Map) {
        final list = (res.data as Map)['services'];
        if (list is List) {
          return list
              .map((item) => CampusServiceModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<ApiResponse> createService({
    required String name,
    required String rate,
    String category = 'Printing',
    String location = '',
    String schedule = '',
    String phone = '',
    String notes = '',
    String? imageUrl,
    String? provider,
    String? campusId,
    String? universityId,
    String? userId,
  }) async {
    return await ApiClient.post(
      ApiConstants.campusServices,
      body: {
        'name': name.trim(),
        'rate': rate.trim(),
        'category': category.trim(),
        'location': location.trim(),
        'schedule': schedule.trim(),
        'phone': phone.trim(),
        'notes': notes.trim(),
        'imageUrl': ?imageUrl,
        'provider': provider ?? 'Student',
        'campusId': campusId,
        'universityId': universityId,
        'userId': userId,
      },
    );
  }

  static Future<bool> updateService({
    required String id,
    required String name,
    required String rate,
    String? category,
    String? location,
    String? schedule,
    String? phone,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        'id': id,
        'name': name.trim(),
        'rate': rate.trim(),
      };
      if (category != null) body['category'] = category.trim();
      if (location != null) body['location'] = location.trim();
      if (schedule != null) body['schedule'] = schedule.trim();
      if (phone != null) body['phone'] = phone.trim();
      if (notes != null) body['notes'] = notes.trim();
      if (imageUrl != null) body['imageUrl'] = imageUrl;

      final res = await ApiClient.patch(
        ApiConstants.campusServices,
        body: body,
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteService(String id) async {
    try {
      final res = await ApiClient.delete('${ApiConstants.campusServices}?id=$id');
      return res.success;
    } catch (_) {
      return false;
    }
  }
}

// Backwards compatibility alias
typedef HostelService = CampusService;
