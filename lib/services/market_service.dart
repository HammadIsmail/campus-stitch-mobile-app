import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/market_item_model.dart';
export '../models/market_item_model.dart';

class MarketService {
  static List<MarketItemModel> _cachedListings = [];
  static bool shouldSimulateOffline = false;

  static List<MarketItemModel> get cachedListings => List.unmodifiable(_cachedListings);
  static set cachedListings(List<MarketItemModel> items) {
    _cachedListings = List.from(items);
  }

  static Future<List<MarketItemModel>> getListings({
    String? campusId,
    String? category,
    String? query,
  }) async {
    if (shouldSimulateOffline) {
      throw Exception('Network unreachable (simulated offline)');
    }
    final queryParams = <String>[];
    if (campusId != null && campusId.isNotEmpty) {
      queryParams.add('campusId=$campusId');
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams.add('category=${Uri.encodeComponent(category)}');
    }
    if (query != null && query.isNotEmpty) {
      queryParams.add('query=${Uri.encodeComponent(query)}');
    }

    final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final res = await ApiClient.get('${ApiConstants.marketListings}$qs');

    if (res.success && res.data is Map) {
      final list = (res.data as Map)['listings'];
      if (list is List) {
        final items = list
            .map((item) => MarketItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        if (items.isNotEmpty) {
          _cachedListings = items;
        }
        return items;
      }
      return [];
    } else {
      throw Exception(res.message ?? 'Failed to load market listings');
    }
  }

  static Future<ApiResponse> createListing({
    required String title,
    required int price,
    required String category,
    String brand = '',
    String condition = 'Used',
    String description = '',
    String location = 'Campus Hostel',
    required String sellerName,
    String? campusId,
    String? imageUrl,
    bool isNegotiable = true,
    Map<String, dynamic> attributes = const {},
  }) async {
    return await ApiClient.post(
      ApiConstants.marketListings,
      body: {
        'title': title.trim(),
        'price': price,
        'category': category,
        'brand': brand.trim(),
        'condition': condition,
        'description': description.trim(),
        'location': location.trim(),
        'seller_name': sellerName.trim(),
        'campus_id': campusId,
        'image_url': imageUrl,
        'is_negotiable': isNegotiable,
        'attributes': attributes,
      },
    );
  }

  static Future<ApiResponse> sendBuyRequest({
    required String listingId,
    required int offerPrice,
    String message = '',
    required String buyerName,
    String? buyerId,
  }) async {
    return await ApiClient.post(
      ApiConstants.marketRequests,
      body: {
        'listingId': listingId,
        'offerPrice': offerPrice,
        'message': message.trim(),
        'buyerName': buyerName,
        'buyerId': buyerId,
      },
    );
  }

  static Future<List<MarketBuyRequestModel>> getBuyRequests({required String listingId}) async {
    try {
      final res = await ApiClient.get('${ApiConstants.marketRequests}?listingId=$listingId');
      if (res.success && res.data is Map) {
        final list = (res.data as Map)['requests'];
        if (list is List) {
          return list
              .map((item) => MarketBuyRequestModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> respondToBuyRequest({
    required String requestId,
    required String listingId,
    required String action, // 'accept' or 'decline'
  }) async {
    try {
      final res = await ApiClient.patch(
        ApiConstants.marketRequests,
        body: {
          'id': requestId,
          'listingId': listingId,
          'action': action,
        },
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> markSoldOut({required String listingId}) async {
    try {
      final res = await ApiClient.patch(
        ApiConstants.marketListings,
        body: {
          'id': listingId,
          'status': 'sold',
        },
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  static Future<ApiResponse> updateListing({
    required String listingId,
    String? title,
    int? price,
    String? category,
    String? condition,
    String? description,
    String? location,
    String? imageUrl,
    String? status,
  }) async {
    return await ApiClient.patch(
      ApiConstants.marketListings,
      body: {
        'id': listingId,
        'title': ?title?.trim(),
        'price': ?price,
        'category': ?category,
        'condition': ?condition,
        'description': ?description?.trim(),
        'location': ?location?.trim(),
        'image_url': ?imageUrl,
        'status': ?status,
      },
    );
  }

  static Future<ApiResponse> deleteListing(String listingId) async {
    return await ApiClient.delete('${ApiConstants.marketListings}?id=$listingId');
  }
}
