class RoommateModel {
  final String id;
  final String title;
  final String rent;
  final int monthlyRent;
  final String details;
  final String roomType;
  final String owner;
  final bool verified;
  final List<String> amenities;
  final String? campusId;
  final String? userId;
  final String createdAt;

  RoommateModel({
    required this.id,
    required this.title,
    required this.rent,
    this.monthlyRent = 0,
    required this.details,
    this.roomType = 'Shared Room',
    required this.owner,
    this.verified = true,
    this.amenities = const [],
    this.campusId,
    this.userId,
    this.createdAt = '',
  });

  factory RoommateModel.fromJson(Map<String, dynamic> json) {
    var rawAmenities = json['amenities'];
    List<String> amenitiesList = [];
    if (rawAmenities is List) {
      amenitiesList = rawAmenities.map((e) => e.toString()).toList();
    }

    final rentStr = json['rent']?.toString() ?? 'Rs. ${json['monthly_rent'] ?? json['monthlyRent'] ?? 0}';
    final rentNum = (json['monthly_rent'] as num?)?.toInt() ??
        (json['monthlyRent'] as num?)?.toInt() ??
        int.tryParse(rentStr.replaceAll(RegExp(r'[^\d]'), '')) ??
        0;

    return RoommateModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      rent: rentStr,
      monthlyRent: rentNum,
      details: json['details']?.toString() ?? '',
      roomType: json['room_type']?.toString() ?? json['roomType']?.toString() ?? 'Shared Room',
      owner: json['user_name']?.toString() ?? json['owner']?.toString() ?? 'Student',
      verified: json['is_verified'] == true || json['verified'] == true,
      amenities: amenitiesList,
      campusId: json['campus_id']?.toString() ?? json['campusId']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  RoommateModel copyWith({
    String? title,
    String? rent,
    int? monthlyRent,
    String? details,
    String? roomType,
    List<String>? amenities,
  }) {
    return RoommateModel(
      id: id,
      title: title ?? this.title,
      rent: rent ?? this.rent,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      details: details ?? this.details,
      roomType: roomType ?? this.roomType,
      owner: owner,
      verified: verified,
      amenities: amenities ?? this.amenities,
      campusId: campusId,
      userId: userId,
      createdAt: createdAt,
    );
  }
}

class HostelServiceModel {
  final String id;
  final String name;
  final String rate;
  final String location;
  final String schedule;
  final String provider;
  final String phone;
  final String notes;
  final bool verified;
  final String? campusId;
  final String? userId;
  final String createdAt;

  HostelServiceModel({
    required this.id,
    required this.name,
    required this.rate,
    required this.location,
    required this.schedule,
    required this.provider,
    this.phone = '',
    this.notes = '',
    this.verified = true,
    this.campusId,
    this.userId,
    this.createdAt = '',
  });

  factory HostelServiceModel.fromJson(Map<String, dynamic> json) {
    return HostelServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['service_name']?.toString() ?? json['name']?.toString() ?? 'Campus Service',
      rate: json['rate']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Hostel Block A',
      schedule: json['turnaround_time']?.toString() ?? json['schedule']?.toString() ?? 'Daily',
      provider: json['provider_name']?.toString() ?? json['provider']?.toString() ?? 'Student',
      phone: json['phone']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      verified: json['is_verified'] == true || json['verified'] == true,
      campusId: json['campus_id']?.toString() ?? json['campusId']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  HostelServiceModel copyWith({
    String? name,
    String? rate,
    String? location,
    String? schedule,
    String? phone,
    String? notes,
  }) {
    return HostelServiceModel(
      id: id,
      name: name ?? this.name,
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
