class CampusServiceModel {
  final String id;
  final String name;
  final String category;
  final String rate;
  final String location;
  final String schedule;
  final String provider;
  final String phone;
  final String notes;
  final String? imageUrl;
  final bool verified;
  final String? campusId;
  final String? userId;
  final String createdAt;

  CampusServiceModel({
    required this.id,
    required this.name,
    this.category = 'Printing',
    required this.rate,
    required this.location,
    required this.schedule,
    required this.provider,
    this.phone = '',
    this.notes = '',
    this.imageUrl,
    this.verified = true,
    this.campusId,
    this.userId,
    this.createdAt = '',
  });

  String get initial => provider.trim().isNotEmpty ? provider.trim()[0].toUpperCase() : 'S';

  factory CampusServiceModel.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['notes']?.toString() ?? '';
    String? img = json['image_url']?.toString() ?? json['imageUrl']?.toString();
    String cleanNotes = rawNotes;
    if (img == null || img.isEmpty) {
      final match = RegExp(r'\[image:\s*([^\]]+)\]').firstMatch(rawNotes);
      if (match != null) {
        img = match.group(1)?.trim();
        cleanNotes = rawNotes.replaceAll(RegExp(r'\[image:\s*[^\]]+\]'), '').trim();
      }
    } else {
      cleanNotes = rawNotes.replaceAll(RegExp(r'\[image:\s*[^\]]+\]'), '').trim();
    }

    return CampusServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['service_name']?.toString() ?? json['name']?.toString() ?? 'Campus Service',
      category: json['category']?.toString() ?? 'Printing',
      rate: json['rate']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      schedule: json['turnaround_time']?.toString() ?? json['schedule']?.toString() ?? '',
      provider: json['provider_name']?.toString() ?? json['provider']?.toString() ?? 'Student',
      phone: json['phone']?.toString() ?? '',
      notes: cleanNotes,
      imageUrl: img,
      verified: json['is_verified'] == true || json['verified'] == true,
      campusId: json['campus_id']?.toString() ?? json['campusId']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'rate': rate,
    'location': location,
    'schedule': schedule,
    'provider': provider,
    'phone': phone,
    'notes': notes,
    'campusId': campusId,
    'userId': userId,
  };

  CampusServiceModel copyWith({
    String? name,
    String? category,
    String? rate,
    String? location,
    String? schedule,
    String? phone,
    String? notes,
  }) {
    return CampusServiceModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      rate: rate ?? this.rate,
      location: location ?? this.location,
      schedule: schedule ?? this.schedule,
      provider: provider,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      verified: verified,
      campusId: campusId,
      userId: userId,
      createdAt: createdAt,
    );
  }
}

// Backwards compatibility alias
typedef HostelServiceModel = CampusServiceModel;
