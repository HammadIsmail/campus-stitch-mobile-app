import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/roommate_model.dart';

class RoommateService {
  static Future<List<RoommatePostModel>> getPosts({
    String? campusId,
    String? type,
  }) async {
    try {
      final queryParams = <String>[];
      if (campusId != null && campusId.isNotEmpty) {
        queryParams.add('campusId=$campusId');
      }
      if (type != null && type.isNotEmpty) {
        queryParams.add('type=${Uri.encodeComponent(type)}');
      }
      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final res = await ApiClient.get('${ApiConstants.roommates}$queryString');

      if (res.success && res.data is Map) {
        final list = (res.data as Map)['posts'];
        if (list is List) {
          return list
              .map((item) => RoommatePostModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<ApiResponse> createPost({
    required String title,
    required double rentAmount,
    required String type, // 'have_room' or 'need_room'
    int seatsOpen = 1,
    int totalSeats = 3,
    required String area,
    required List<String> preferences,
    String about = '',
    required String who,
    String phone = '',
    String? imageUrl,
    String? campusId,
    String? userId,
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
      'rentAmount': rentAmount,
      'rent': 'Rs ${rentAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} / mo',
      'type': type,
      'seatsOpen': seatsOpen,
      'totalSeats': totalSeats,
      'area': area.trim(),
      'preferences': preferences,
      'about': about.trim(),
      'who': who.trim(),
      'phone': phone.trim(),
      'imageUrl': ?imageUrl,
      'campusId': ?campusId,
      'userId': ?userId,
    };
    return await ApiClient.post(ApiConstants.roommates, body: body);
  }

  static Future<ApiResponse> updatePost({
    required String id,
    String? title,
    double? rentAmount,
    String? type,
    String? area,
    List<String>? preferences,
    String? about,
    String? phone,
    String? imageUrl,
    String? status,
  }) async {
    final body = <String, dynamic>{
      'id': id,
      'title': ?title?.trim(),
      'rentAmount': ?rentAmount,
      'type': ?type,
      'area': ?area?.trim(),
      'preferences': ?preferences,
      'about': ?about?.trim(),
      'phone': ?phone?.trim(),
      'imageUrl': ?imageUrl,
      'status': ?status,
    };
    return await ApiClient.patch(ApiConstants.roommates, body: body);
  }

  static Future<ApiResponse> deletePost(String id) async {
    return await ApiClient.delete('${ApiConstants.roommates}?id=$id');
  }
}

