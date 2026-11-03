class RatingModel {
  final String id;
  final String userId;
  final String raterId;
  final String raterName;
  final int rating;
  final String category;
  final List<String> tags;
  final String comment;
  final DateTime createdAt;
  final String? transactionId;
  final String? campusId;

  RatingModel({
    required this.id,
    required this.userId,
    required this.raterId,
    required this.raterName,
    required this.rating,
    required this.category,
    this.tags = const [],
    required this.comment,
    required this.createdAt,
    this.transactionId,
    this.campusId,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((t) => t.toString()).toList();
    }

    return RatingModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      raterId: json['rater_id']?.toString() ?? '',
      raterName: json['rater_name']?.toString() ?? 'Campus Peer',
      rating: (json['rating'] is num) ? (json['rating'] as num).toInt() : 5,
      category: json['category']?.toString() ?? 'general',
      tags: parsedTags,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      transactionId: json['transaction_id']?.toString(),
      campusId: json['campus_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'rater_id': raterId,
      'rater_name': raterName,
      'rating': rating,
      'category': category,
      'tags': tags,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'transaction_id': transactionId,
      'campus_id': campusId,
    };
  }
}

class RatingBreakdownModel {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> breakdown;
  final List<RatingModel> reviews;

  RatingBreakdownModel({
    required this.averageRating,
    required this.totalReviews,
    required this.breakdown,
    required this.reviews,
  });

  factory RatingBreakdownModel.empty() {
    return RatingBreakdownModel(
      averageRating: 0.0,
      totalReviews: 0,
      breakdown: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      reviews: [],
    );
  }

  factory RatingBreakdownModel.fromJson(Map<String, dynamic> json) {
    final Map<int, int> b = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    if (json['breakdown'] is Map) {
      final raw = json['breakdown'] as Map;
      for (int i = 1; i <= 5; i++) {
        if (raw[i.toString()] is num) {
          b[i] = (raw[i.toString()] as num).toInt();
        } else if (raw[i] is num) {
          b[i] = (raw[i] as num).toInt();
        }
      }
    }

    List<RatingModel> revs = [];
    if (json['reviews'] is List) {
      revs = (json['reviews'] as List)
          .map((r) => RatingModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return RatingBreakdownModel(
      averageRating: (json['averageRating'] is num)
          ? (json['averageRating'] as num).toDouble()
          : 0.0,
      totalReviews: (json['totalReviews'] is num)
          ? (json['totalReviews'] as num).toInt()
          : revs.length,
      breakdown: b,
      reviews: revs,
    );
  }
}
