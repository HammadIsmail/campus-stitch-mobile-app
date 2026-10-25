import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/hostel_model.dart';

class HostelService {
  // Roommates
  static Future<List<RoommateModel>> getRoommates({String? campusId}) async {
    try {
      final url = campusId != null && campusId.isNotEmpty
          ? '${ApiConstants.hostelRoommates}?campusId=$campusId'
          : ApiConstants.hostelRoommates;
      final res = await ApiClient.get(url);
      if (res.success && res.data is Map) {
        final list = (res.data as Map)['roommates'];
        if (list is List) {
          return list
              .map((item) => RoommateModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<ApiResponse> createRoommate({
    required String title,
    required String monthlyRent,
    String roomType = 'Shared Room',
    String details = '',
    List<String> amenities = const [],
    String? campusId,
    String? universityId,
    String? userName,
    String? userId,
  }) async {
    return await ApiClient.post(
      ApiConstants.hostelRoommates,
      body: {
        'title': title.trim(),
        'monthlyRent': monthlyRent.trim(),
        'roomType': roomType,
        'details': details.trim(),
        'amenities': amenities,
        'campusId': campusId,
        'universityId': universityId,
        'userName': userName ?? 'Student',
        'userId': userId,
      },
    );
  }

  static Future<bool> updateRoommate({
    required String id,
    required String title,
    required String monthlyRent,
    String? roomType,
    String? details,
    List<String>? amenities,
  }) async {
    try {
      final body = <String, dynamic>{
        'id': id,
        'title': title.trim(),
        'monthlyRent': monthlyRent.trim(),
      };
      if (roomType != null) body['roomType'] = roomType;
      if (details != null) body['details'] = details.trim();
      if (amenities != null) body['amenities'] = amenities;

      final res = await ApiClient.patch(
        ApiConstants.hostelRoommates,
        body: body,
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteRoommate(String id) async {
    try {
      final res = await ApiClient.delete('${ApiConstants.hostelRoommates}?id=$id');
      return res.success;
    } catch (_) {
      return false;
    }
  }

  // Student Services
  static Future<List<HostelServiceModel>> getServices({String? campusId}) async {
    try {
      final url = campusId != null && campusId.isNotEmpty
          ? '${ApiConstants.hostelServices}?campusId=$campusId'
          : ApiConstants.hostelServices;
      final res = await ApiClient.get(url);
      if (res.success && res.data is Map) {
        final list = (res.data as Map)['services'];
        if (list is List) {
          return list
              .map((item) => HostelServiceModel.fromJson(Map<String, dynamic>.from(item)))
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
      ApiConstants.hostelServices,
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
        ApiConstants.hostelServices,
        body: body,
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteService(String id) async {
    try {
      final res = await ApiClient.delete('${ApiConstants.hostelServices}?id=$id');
      return res.success;
    } catch (_) {
      return false;
    }
  }
}
