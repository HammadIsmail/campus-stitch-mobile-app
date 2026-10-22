class Campus {
  final String id;
  final String universityId;
  final String name;
  final String city;
  final String address;
  final String contactEmail;
  final bool isActive;

  Campus({
    required this.id,
    required this.universityId,
    required this.name,
    required this.city,
    this.address = '',
    this.contactEmail = '',
    this.isActive = true,
  });

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      id: json['id']?.toString() ?? '',
      universityId: json['university_id']?.toString() ?? json['universityId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? json['contactEmail']?.toString() ?? '',
      isActive: json['is_active'] == true || json['isActive'] == true || json['is_active'] == null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university_id': universityId,
      'name': name,
      'city': city,
      'address': address,
      'contact_email': contactEmail,
      'is_active': isActive,
    };
  }
}

class University {
  final String id;
  final String name;
  final String shortName;
  final String city;
  final String website;
  final List<Campus> campuses;

  University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.city,
    this.website = '',
    this.campuses = const [],
  });

  factory University.fromJson(Map<String, dynamic> json) {
    List<Campus> camps = [];
    if (json['campuses'] != null && json['campuses'] is List) {
      camps = (json['campuses'] as List).map((c) {
        if (c is Map<String, dynamic>) {
          return Campus.fromJson(c);
        } else {
          return Campus(
            id: 'camp_${c.toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
            universityId: json['id']?.toString() ?? '',
            name: c.toString(),
            city: json['city']?.toString() ?? '',
          );
        }
      }).toList();
    }

    return University(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortName: json['short_name']?.toString() ?? json['shortName']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      campuses: camps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'city': city,
      'website': website,
      'campuses': campuses.map((c) => c.toJson()).toList(),
    };
  }
}
