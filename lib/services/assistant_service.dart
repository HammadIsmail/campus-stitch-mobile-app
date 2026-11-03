import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/ai_search_model.dart';

class AssistantResponse {
  final String reply;
  final String? optionsType;
  final List<String> chips;
  final List<Map<String, dynamic>> rides;
  final List<Map<String, dynamic>> bikes;
  final List<Map<String, dynamic>> listings;
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> communities;
  final List<Map<String, dynamic>> profiles;

  AssistantResponse({
    required this.reply,
    this.optionsType,
    required this.chips,
    required this.rides,
    required this.bikes,
    required this.listings,
    required this.services,
    required this.communities,
    required this.profiles,
  });

  factory AssistantResponse.fromJson(Map<String, dynamic> json) {
    return AssistantResponse(
      reply: json['reply'] as String? ?? 'Here are the campus records I found:',
      optionsType: json['optionsType'] as String?,
      chips: (json['chips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rides: (json['rides'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      bikes: (json['bikes'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      listings: (json['listings'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      services: (json['services'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      communities: (json['communities'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      profiles: (json['profiles'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
    );
  }
}

class AssistantService {
  /// Legacy assistant ask method
  static Future<AssistantResponse?> askAssistant(String query) async {
    try {
      final res = await ApiClient.post(
        ApiConstants.assistantChat,
        body: {'query': query},
      );
      if (res.success && res.data != null) {
        return AssistantResponse.fromJson(res.data);
      }
    } catch (e) {
      debugPrint('Error asking assistant: $e');
    }
    return null;
  }

  /// Campus AI Search (English, Urdu, Roman Urdu) with server-side tenant isolation
  static Future<AiSearchResultModel?> searchCampusAi({
    required String query,
    required String campusId,
    required String campusName,
  }) async {
    try {
      final payload = {
        'query': query.trim(),
        'campus_id': campusId,
        'campus_name': campusName,
      };

      final res = await ApiClient.post(
        ApiConstants.assistantChat,
        body: payload,
      );

      if (res.success && res.data is Map) {
        return AiSearchResultModel.fromJson(Map<String, dynamic>.from(res.data as Map));
      }
    } catch (e) {
      debugPrint('Error performing Campus AI search: $e');
    }
    return null;
  }
}
