import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api/api_constants.dart';
import '../core/storage/session_store.dart';
import '../models/rating_model.dart';

class RatingService {
  /// Fetch rating profile and reviews for a user
  static Future<RatingBreakdownModel> getUserRatings({
    required String userId,
    required String campusId,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.ratings}?userId=$userId&campus_id=$campusId');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return RatingBreakdownModel.fromJson(body);
      }
    } catch (e) {
      debugPrint('Error fetching user ratings: $e');
    }
    return RatingBreakdownModel.empty();
  }

  /// Submit a rating for a completed transaction
  static Future<Map<String, dynamic>> submitRating({
    required String userId,
    required int rating,
    required List<String> tags,
    String? comment,
    String? transactionId,
    String? category,
    required String campusId,
  }) async {
    try {
      final user = await SessionStore.getUser();
      final payload = {
        'userId': userId,
        'rating': rating,
        'tags': tags,
        'comment': comment?.trim() ?? '',
        'transaction_id': transactionId,
        'category': category ?? 'general',
        'campus_id': campusId,
        'raterId': user?.id ?? 'u_peer',
        'raterName': user?.fullName ?? 'Student Peer',
        'raterStudentId': user?.studentId ?? '2023-CS-000',
      };

      final res = await http.post(
        Uri.parse(ApiConstants.ratings),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return {'success': true, 'data': body};
      } else {
        final body = jsonDecode(res.body);
        return {'success': false, 'error': body['error'] ?? 'Failed to submit rating'};
      }
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      return {'success': false, 'error': 'Network error submitting rating'};
    }
  }
}
