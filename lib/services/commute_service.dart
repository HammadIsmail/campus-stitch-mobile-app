import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/storage/commute_store.dart';
import '../models/ride_model.dart';

class CommuteService {
  /// Fetches all active rides with offline-first synchronization
  static Future<List<RideModel>> getRides({
    required String campusId,
    String? query,
    String? vehicleType,
  }) async {
    // 1. Fetch latest rides from backend API
    try {
      final params = <String, String>{'campusId': campusId};
      if (vehicleType != null && vehicleType.isNotEmpty) {
        params['vehicleType'] = vehicleType;
      }
      if (query != null && query.trim().isNotEmpty) {
        params['query'] = query.trim();
      }

      final queryString = Uri(queryParameters: params).query;
      final url = '${ApiConstants.commuteRides}?$queryString';
      final res = await ApiClient.get(url);

      if (res.success && res.data is Map && (res.data as Map)['rides'] is List) {
        final serverList = ((res.data as Map)['rides'] as List)
            .map((item) => RideModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        // Update local store with authoritative backend state
        await CommuteStore.saveRides(serverList);
        return _filterRides(serverList, query, vehicleType);
      }
    } catch (_) {
      // Offline fallback: load local cache
    }

    final localRides = await CommuteStore.loadRides();
    return _filterRides(localRides, query, vehicleType);
  }

  static List<RideModel> _filterRides(List<RideModel> rides, String? query, String? vehicleType) {
    var result = rides;
    if (vehicleType != null && vehicleType.isNotEmpty && vehicleType != 'all') {
      result = result.where((r) => r.vehicleType == vehicleType).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((r) =>
        r.fromLocation.toLowerCase().contains(q) ||
        r.toLocation.toLowerCase().contains(q) ||
        r.organizerName.toLowerCase().contains(q) ||
        r.pickupPoint.toLowerCase().contains(q)
      ).toList();
    }
    return result;
  }

  /// Posts a new campus ride
  static Future<RideModel> createRide({
    required String campusId,
    required String universityId,
    required String organizerName,
    required String fromLocation,
    required String toLocation,
    required String departureTime,
    String departureDate = 'Today',
    required String vehicleType,
    required int totalCost,
    required int pricePerSeat,
    required int totalSeats,
    required int availableSeats,
    String pickupPoint = 'Main road stop',
    String notes = '',
  }) async {
    final newRide = RideModel(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      campusId: campusId,
      universityId: universityId,
      organizerName: organizerName,
      organizerVerified: true,
      fromLocation: fromLocation.trim(),
      toLocation: toLocation.trim(),
      departureTime: departureTime.trim(),
      departureDate: departureDate.trim(),
      vehicleType: vehicleType.toLowerCase(),
      totalCost: totalCost,
      pricePerSeat: pricePerSeat,
      totalSeats: totalSeats,
      availableSeats: availableSeats,
      pickupPoint: pickupPoint.trim(),
      notes: notes.trim(),
      status: 'active',
      createdAt: DateTime.now().toIso8601String(),
    );

    // Save to local storage immediately
    await CommuteStore.addRide(newRide);

    // Dispatch to server in background / await
    try {
      final res = await ApiClient.post(
        ApiConstants.commuteRides,
        body: newRide.toJson(),
      );
      if (res.success && res.data is Map && (res.data as Map)['ride'] != null) {
        final serverRide = RideModel.fromJson(Map<String, dynamic>.from((res.data as Map)['ride']));
        await CommuteStore.addRide(serverRide);
        return serverRide;
      }
    } catch (_) {}

    return newRide;
  }

  /// Books a seat on an existing ride
  static Future<bool> bookRideSeat({
    required RideModel ride,
    required String riderName,
  }) async {
    if (ride.availableSeats <= 0) return false;

    final updatedRide = ride.copyWith(availableSeats: ride.availableSeats - 1);
    await CommuteStore.addRide(updatedRide);

    final booking = RideBookingModel(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      rideId: ride.id,
      riderName: riderName,
      route: '${ride.fromLocation} → ${ride.toLocation}',
      departureTime: ride.departureTime,
      pricePerSeat: ride.pricePerSeat,
      vehicleType: ride.vehicleType,
      organizerName: ride.organizerName,
      date: DateTime.now().toIso8601String(),
      status: 'confirmed',
    );
    await CommuteStore.addBooking(booking);

    try {
      await ApiClient.post(
        ApiConstants.commuteBook,
        body: {
          'rideId': ride.id,
          'riderName': riderName,
          'seats': 1,
        },
      );
    } catch (_) {}

    return true;
  }

  /// Fetches user's ride bookings
  static Future<List<RideBookingModel>> getBookings() async {
    return await CommuteStore.loadBookings();
  }

  /// Fetches campus bikes
  static Future<List<BikeModel>> getBikes({required String campusId}) async {
    try {
      final url = '${ApiConstants.commuteBikes}?campusId=$campusId';
      final res = await ApiClient.get(url);
      if (res.success && res.data is Map && (res.data as Map)['bikes'] is List) {
        return ((res.data as Map)['bikes'] as List)
            .map((b) => BikeModel.fromJson(Map<String, dynamic>.from(b)))
            .toList();
      }
    } catch (_) {}

    return [];
  }
}
