import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

class MarketItemModel {
  final String id;
  final String title;
  final int price;
  final String category;
  final String sellerName;
  final bool isVerified;
  final String condition;
  final String campusId;
  final String? description;
  final String? location;
  final String? imageUrl;
  final String? createdAt;

  MarketItemModel({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.sellerName,
    this.isVerified = true,
    required this.condition,
    required this.campusId,
    this.description,
    this.location,
    this.imageUrl,
    this.createdAt,
  });

  factory MarketItemModel.fromJson(Map<String, dynamic> json) {
    return MarketItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: json['price'] is num ? (json['price'] as num).toInt() : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      category: json['category']?.toString() ?? 'Other',
      sellerName: json['seller_name']?.toString() ?? 'Student',
      isVerified: json['seller_verified'] == true || json['is_verified'] == true,
      condition: json['condition']?.toString() ?? 'Good',
      campusId: json['campus_id']?.toString() ?? '',
      description: json['description']?.toString(),
      location: json['location']?.toString(),
      imageUrl: json['image_url']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'category': category,
      'seller_name': sellerName,
      'seller_verified': isVerified,
      'condition': condition,
      'campus_id': campusId,
      'description': description,
      'location': location,
      'image_url': imageUrl,
      'created_at': createdAt,
    };
  }
}

class MarketService {
  /// Fetches real market listings from backend API
  static Future<List<MarketItemModel>> getListings({
    required String campusId,
    String? category,
    String? query,
  }) async {
    try {
      final params = <String, String>{'campusId': campusId};
      if (category != null && category.isNotEmpty && category != 'All') {
        params['category'] = category;
      }
      if (query != null && query.trim().isNotEmpty) {
        params['query'] = query.trim();
      }

      final queryString = Uri(queryParameters: params).query;
      final url = '${ApiConstants.marketListings}?$queryString';
      final res = await ApiClient.get(url);

      if (res.success && res.data is Map && (res.data as Map)['listings'] is List) {
        final list = (res.data as Map)['listings'] as List;
        return list.map((item) => MarketItemModel.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (_) {}

    // Honest empty state when database has 0 listings
    return [];
  }

  /// Posts a new marketplace listing
  static Future<bool> createListing({
    required String campusId,
    required String universityId,
    required String sellerName,
    required String title,
    required int price,
    required String category,
    required String condition,
    required String description,
    required String location,
  }) async {
    try {
      final res = await ApiClient.post(
        ApiConstants.marketListings,
        body: {
          'campus_id': campusId,
          'university_id': universityId,
          'seller_name': sellerName,
          'title': title.trim(),
          'price': price,
          'category': category,
          'condition': condition,
          'description': description.trim(),
          'location': location.trim(),
        },
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  /// Updates listing status (e.g. 'sold', 'reserved') or price
  static Future<bool> updateListing({
    required String id,
    String? status,
    int? price,
    String? title,
  }) async {
    try {
      final body = <String, dynamic>{'id': id};
      if (status != null) body['status'] = status;
      if (price != null) body['price'] = price;
      if (title != null) body['title'] = title;
      final res = await ApiClient.patch(
        ApiConstants.marketListings,
        body: body,
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  /// Deletes a listing
  static Future<bool> deleteListing(String id) async {
    try {
      final res = await ApiClient.delete(
        '${ApiConstants.marketListings}?id=$id',
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }
}
