class RoommatePostModel {
  final String id;
  final String? campusId;
  final String? userId;
  final String type; // 'have_room' or 'need_room'
  final String title;
  final String rent;
  final double rentAmount;
  final int seatsOpen;
  final int totalSeats;
  final String area;
  final String who;
  final String phone;
  final String about;
  final String? imageUrl;
  final List<String> tags;
  final String createdAt;

  RoommatePostModel({
    required this.id,
    this.campusId,
    this.userId,
    this.type = 'have_room',
    required this.title,
    required this.rent,
    this.rentAmount = 0,
    this.seatsOpen = 1,
    this.totalSeats = 1,
    required this.area,
    required this.who,
    this.phone = '',
    this.about = '',
    this.imageUrl,
    this.tags = const [],
    this.createdAt = '',
  });

  String get initial => who.trim().isNotEmpty ? who.trim()[0].toUpperCase() : 'S';

  factory RoommatePostModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((t) => t.toString()).toList();
    } else if (json['preferences'] is List) {
      parsedTags = (json['preferences'] as List).map((t) => t.toString()).toList();
    }

    String rawAbout = json['about']?.toString() ?? json['about_room']?.toString() ?? json['details']?.toString() ?? '';
    String? imgUrl = json['imageUrl']?.toString() ?? json['image_url']?.toString();
    if (imgUrl == null || imgUrl.isEmpty) {
      final match = RegExp(r'\[image:\s*([^\]]+)\]').firstMatch(rawAbout);
      if (match != null) {
        imgUrl = match.group(1)?.trim();
        rawAbout = rawAbout.replaceAll(RegExp(r'\[image:\s*[^\]]+\]'), '').trim();
      }
    } else {
      rawAbout = rawAbout.replaceAll(RegExp(r'\[image:\s*[^\]]+\]'), '').trim();
    }

    final double rentAmt = (json['rentAmount'] != null)
        ? (json['rentAmount'] as num).toDouble()
        : (json['monthly_rent'] != null)
            ? (json['monthly_rent'] as num).toDouble()
            : 0.0;

    final rentString = json['rent']?.toString() ?? (rentAmt > 0 ? 'Rs ${rentAmt.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} / mo' : '');

    return RoommatePostModel(
      id: json['id']?.toString() ?? '',
      campusId: json['campus_id']?.toString() ?? json['campusId']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      type: json['type']?.toString() ?? json['room_type']?.toString() ?? 'have_room',
      title: json['title']?.toString() ?? '',
      rent: rentString,
      rentAmount: rentAmt,
      seatsOpen: int.tryParse(json['seatsOpen']?.toString() ?? json['seats_open']?.toString() ?? '1') ?? 1,
      totalSeats: int.tryParse(json['totalSeats']?.toString() ?? json['total_seats']?.toString() ?? '1') ?? 1,
      area: json['area']?.toString() ?? json['hostel_block']?.toString() ?? '',
      who: json['who']?.toString() ?? json['user_name']?.toString() ?? 'Student',
      phone: json['phone']?.toString() ?? '',
      about: rawAbout,
      imageUrl: imgUrl,
      tags: parsedTags,
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'campusId': campusId,
    'userId': userId,
    'type': type,
    'title': title,
    'rent': rent,
    'rentAmount': rentAmount,
    'seatsOpen': seatsOpen,
    'totalSeats': totalSeats,
    'area': area,
    'who': who,
    'phone': phone,
    'about': about,
    'imageUrl': imageUrl,
    'tags': tags,
  };
}
