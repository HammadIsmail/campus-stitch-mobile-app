class MarketItemModel {
  final String id;
  final String title;
  final int price;
  final String category;
  final String brand;
  final String sellerName;
  final String? sellerId;
  final bool isVerified;
  final String condition;
  final String campusId;
  final String? description;
  final String? location;
  final String? imageUrl;
  final bool isNegotiable;
  final String status; // 'available', 'reserved', 'sold'
  final Map<String, dynamic> attributes;
  final String? createdAt;
  bool isRequested;

  MarketItemModel({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    this.brand = '',
    required this.sellerName,
    this.sellerId,
    this.isVerified = true,
    required this.condition,
    required this.campusId,
    this.description,
    this.location = 'Campus Hostel',
    this.imageUrl,
    this.isNegotiable = true,
    this.status = 'available',
    this.attributes = const {},
    this.createdAt,
    this.isRequested = false,
  });

  bool get isSold => status == 'sold';
  String get priceText => 'Rs ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  String get metaText => '$condition · ${location ?? 'Hostel'}';
  String? get phone => attributes['phone']?.toString() ?? (description != null && description!.contains('Phone: ') ? description!.split('Phone: ')[1].trim() : null);

  factory MarketItemModel.fromJson(Map<String, dynamic> json) {
    return MarketItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toInt()
          : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      category: json['category']?.toString() ?? 'Other',
      brand: json['brand']?.toString() ?? '',
      sellerName: json['seller_name']?.toString() ?? 'Student',
      sellerId: json['seller_id']?.toString(),
      isVerified: json['seller_verified'] == true || json['is_verified'] == true,
      condition: json['condition']?.toString() ?? 'Good',
      campusId: json['campus_id']?.toString() ?? '',
      description: json['description']?.toString(),
      location: json['location']?.toString() ?? 'Hostel',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      isNegotiable: json['is_negotiable'] ?? true,
      status: json['status']?.toString() ?? 'available',
      attributes: json['attributes'] is Map ? Map<String, dynamic>.from(json['attributes']) : {},
      createdAt: json['created_at']?.toString(),
      isRequested: json['is_requested'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'category': category,
      'brand': brand,
      'seller_name': sellerName,
      'seller_id': sellerId,
      'seller_verified': isVerified,
      'condition': condition,
      'campus_id': campusId,
      'description': description,
      'location': location,
      'image_url': imageUrl,
      'is_negotiable': isNegotiable,
      'status': status,
      'attributes': attributes,
      'created_at': createdAt,
    };
  }
}

class MarketBuyRequestModel {
  final String id;
  final String listingId;
  final String name;
  final String initial;
  final String rating;
  final String offer;
  final int offerPrice;
  final String msg;
  final String status;
  final String createdAt;

  String get offerText => offer;

  MarketBuyRequestModel({
    required this.id,
    required this.listingId,
    required this.name,
    required this.initial,
    required this.rating,
    required this.offer,
    required this.offerPrice,
    required this.msg,
    this.status = 'pending',
    this.createdAt = '',
  });

  factory MarketBuyRequestModel.fromJson(Map<String, dynamic> json) {
    final offerP = json['offerPrice'] is num
        ? (json['offerPrice'] as num).toInt()
        : json['offer_price'] is num
            ? (json['offer_price'] as num).toInt()
            : 0;
    return MarketBuyRequestModel(
      id: json['id']?.toString() ?? '',
      listingId: json['listingId']?.toString() ?? json['listing_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['buyer_name']?.toString() ?? 'Student',
      initial: json['initial']?.toString() ?? ((json['name']?.toString() ?? 'S')[0].toUpperCase()),
      rating: json['rating']?.toString() ?? json['buyer_rating']?.toString() ?? '',
      offer: json['offer']?.toString() ?? (offerP > 0 ? 'Rs $offerP' : ''),
      offerPrice: offerP,
      msg: json['msg']?.toString() ?? json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

