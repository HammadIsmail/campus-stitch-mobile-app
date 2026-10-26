class CampusServiceModel {
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

  CampusServiceModel({
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

  factory CampusServiceModel.fromJson(Map<String, dynamic> json) {
    return CampusServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['service_name']?.toString() ?? json['name']?.toString() ?? 'Campus Service',
      rate: json['rate']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Campus Service Point',
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

  CampusServiceModel copyWith({
    String? name,
    String? rate,
    String? location,
    String? schedule,
    String? phone,
    String? notes,
  }) {
    return CampusServiceModel(
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

// Backwards compatibility alias
typedef HostelServiceModel = CampusServiceModel;
