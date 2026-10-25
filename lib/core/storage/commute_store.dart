import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/ride_model.dart';

class CommuteStore {
  static const String _ridesFileName = '.campus_stitch_rides.json';
  static const String _bookingsFileName = '.campus_stitch_bookings.json';

  static List<RideModel>? _memoryRides;
  static List<RideBookingModel>? _memoryBookings;

  static File? _getFile(String fileName) {
    if (kIsWeb) return null;
    try {
      if (Platform.isAndroid) {
        final internalDir = Directory('/data/user/0/com.campusstitch.app/files');
        if (internalDir.existsSync()) {
          return File('${internalDir.path}/$fileName');
        }
        final fallbackDir = Directory('/data/data/com.campusstitch.app/files');
        if (fallbackDir.existsSync()) {
          return File('${fallbackDir.path}/$fileName');
        }
      }
      final dir = Directory.systemTemp;
      return File('${dir.path}/$fileName');
    } catch (_) {
      return null;
    }
  }

  // --- RIDES ---
  static Future<List<RideModel>> loadRides() async {
    if (_memoryRides != null && _memoryRides!.isNotEmpty) {
      return List<RideModel>.from(_memoryRides!);
    }

    final file = _getFile(_ridesFileName);
    if (file != null && await file.exists()) {
      try {
        final content = await file.readAsString();
        final decoded = jsonDecode(content);
        if (decoded is List) {
          final list = decoded
              .map((item) => RideModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          _memoryRides = list;
          return List<RideModel>.from(list);
        }
      } catch (e) {
        debugPrint('Error loading cached rides: $e');
      }
    }

    return [];
  }

  static Future<void> saveRides(List<RideModel> rides) async {
    _memoryRides = List<RideModel>.from(rides);
    final file = _getFile(_ridesFileName);
    if (file != null) {
      try {
        final data = rides.map((r) => r.toJson()).toList();
        await file.writeAsString(jsonEncode(data));
      } catch (e) {
        debugPrint('Error saving rides to storage: $e');
      }
    }
  }

  static Future<void> addRide(RideModel ride) async {
    final current = await loadRides();
    current.removeWhere((r) => r.id == ride.id);
    current.insert(0, ride);
    await saveRides(current);
  }

  // --- BOOKINGS ---
  static Future<List<RideBookingModel>> loadBookings() async {
    if (_memoryBookings != null) {
      return List<RideBookingModel>.from(_memoryBookings!);
    }

    final file = _getFile(_bookingsFileName);
    if (file != null && await file.exists()) {
      try {
        final content = await file.readAsString();
        final decoded = jsonDecode(content);
        if (decoded is List) {
          final list = decoded
              .map((item) => RideBookingModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          _memoryBookings = list;
          return List<RideBookingModel>.from(list);
        }
      } catch (e) {
        debugPrint('Error loading bookings: $e');
      }
    }

    return [];
  }

  static Future<void> saveBookings(List<RideBookingModel> bookings) async {
    _memoryBookings = List<RideBookingModel>.from(bookings);
    final file = _getFile(_bookingsFileName);
    if (file != null) {
      try {
        final data = bookings.map((b) => b.toJson()).toList();
        await file.writeAsString(jsonEncode(data));
      } catch (e) {
        debugPrint('Error saving bookings: $e');
      }
    }
  }

  static Future<void> addBooking(RideBookingModel booking) async {
    final current = await loadBookings();
    current.insert(0, booking);
    await saveBookings(current);
  }
}
