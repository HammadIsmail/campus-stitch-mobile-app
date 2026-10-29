import 'dart:convert';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

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
  static Future<AssistantResponse?> askAssistant(String query) async {
    try {
      final res = await ApiClient.post(
        ApiConstants.assistantChat,
        body: {'query': query},
      );
      if (res.success && res.data != null) {
        final Map<String, dynamic> json = res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : (res.data is String ? jsonDecode(res.data) : {});
        return AssistantResponse.fromJson(json);
      }
    } catch (_) {}
    return null;
  }
}
