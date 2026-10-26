import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/service_model.dart';

class CampusService {
  // Student Campus Services
  static Future<List<CampusServiceModel>> getServices({String? campusId}) async {
    try {
      final url = campusId != null && campusId.isNotEmpty
          ? '${ApiConstants.campusServices}?campusId=$campusId'
          : ApiConstants.campusServices;
      final res = await ApiClient.get(url);
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
    String location = 'Hostel Block A',
    String schedule = 'Daily 5 PM – 10 PM',
    String phone = '',
    String notes = '',
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
        'location': location.trim(),
        'schedule': schedule.trim(),
        'phone': phone.trim(),
        'notes': notes.trim(),
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
    String? location,
    String? schedule,
    String? phone,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'id': id,
        'name': name.trim(),
        'rate': rate.trim(),
      };
      if (location != null) body['location'] = location.trim();
      if (schedule != null) body['schedule'] = schedule.trim();
      if (phone != null) body['phone'] = phone.trim();
      if (notes != null) body['notes'] = notes.trim();

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
