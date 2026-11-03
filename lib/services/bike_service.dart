import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/bike_model.dart';
export '../models/bike_model.dart';

class BikeService {
  static Future<List<BikeModel>> getBikes({String? campusId}) async {
    try {
      final url = campusId != null && campusId.isNotEmpty
          ? '${ApiConstants.commuteBikes}?campusId=$campusId'
          : ApiConstants.commuteBikes;
      final res = await ApiClient.get(url);
      if (res.success && res.data is Map) {
        final list = (res.data as Map)['bikes'];
        if (list is List) {
          return list
              .map((item) => BikeModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<ApiResponse> listBike({
    required String model,
    required double hourlyRate,
    required double dailyRate,
    required String pickupSpot,
    String availableFrom = '4:00 PM',
    String untilTime = '9:00 PM',
    List<String> days = const ['M', 'T', 'W', 'T', 'F'],
    bool helmetIncluded = true,
    required String ownerName,
    String? campusId,
  }) async {
    return await ApiClient.post(
      ApiConstants.commuteBikes,
      body: {
        'model': model.trim(),
        'dailyRate': dailyRate,
        'hourlyRate': hourlyRate,
        'location': pickupSpot.trim(),
        'available_time': '$availableFrom to $untilTime',
        'available_from': availableFrom,
        'until_time': untilTime,
        'helmet_included': helmetIncluded,
        'ownerName': ownerName.trim(),
        'campusId': campusId,
      },
    );
  }

  static Future<List<BikeRequestModel>> getRequests({String? bikeId, String? status}) async {
    try {
      final queryParams = <String>[];
      if (bikeId != null && bikeId.isNotEmpty) queryParams.add('bikeId=$bikeId');
      if (status != null && status.isNotEmpty) queryParams.add('status=$status');
      final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';

      final res = await ApiClient.get('${ApiConstants.bikeRequests}$qs');
      if (res.success && res.data is Map) {
        final list = (res.data as Map)['requests'];
        if (list is List) {
          return list
              .map((item) => BikeRequestModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<ApiResponse> requestBikeRental({
    required String bikeId,
    required String renterName,
    required String slotDay,
    required String slotTime,
    String note = '',
  }) async {
    return await ApiClient.post(
      ApiConstants.bikeRequests,
      body: {
        'bikeId': bikeId,
        'renterName': renterName,
        'slotDay': slotDay,
        'slotTime': slotTime,
        'note': note,
      },
    );
  }

  static Future<bool> respondToRequest({
    required String id,
    required String action, // 'accept', 'decline', 'return'
  }) async {
    try {
      final res = await ApiClient.patch(
        ApiConstants.bikeRequests,
        body: {
          'id': id,
          'action': action,
        },
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateBikeAvailability({
    required String bikeId,
    required bool isAvailable,
  }) async {
    try {
      final res = await ApiClient.patch(
        ApiConstants.commuteBikes,
        body: {
          'bikeId': bikeId,
          'isAvailable': isAvailable,
        },
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  static Future<ApiResponse> updateBike({
    required String bikeId,
    String? model,
    double? hourlyRate,
    double? dailyRate,
    String? location,
    bool? isAvailable,
    String? imageUrl,
  }) async {
    return await ApiClient.patch(
      ApiConstants.commuteBikes,
      body: {
        'bikeId': bikeId,
        'model': ?model?.trim(),
        'dailyRate': ?dailyRate,
        'location': ?location?.trim(),
        'isAvailable': ?isAvailable,
        'imageUrl': ?imageUrl,
      },
    );
  }

  static Future<ApiResponse> deleteBike(String bikeId) async {
    return await ApiClient.delete('${ApiConstants.commuteBikes}?id=$bikeId');
  }
}

