class CommunityModel {
  final String id;
  final String name;
  final String title;
  final String description;
  final String category;
  final int memberCount;
  final bool isJoined;
  final List<String> rules;

  CommunityModel({
    required this.id,
    required this.name,
    required this.title,
    this.description = '',
    this.category = 'General',
    this.memberCount = 1,
    this.isJoined = false,
    this.rules = const [],
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    var rawRules = json['rules'];
    List<String> rulesList = [];
    if (rawRules is List) {
      rulesList = rawRules.map((e) => e.toString()).toList();
    }

    return CommunityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      memberCount: (json['member_count'] as num?)?.toInt() ??
          (json['memberCount'] as num?)?.toInt() ??
          1,
      isJoined: json['isJoined'] == true || json['is_joined'] == true,
      rules: rulesList,
    );
  }

  CommunityModel copyWith({
    String? id,
    String? name,
    String? title,
    String? description,
    String? category,
    int? memberCount,
    bool? isJoined,
    List<String>? rules,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
      rules: rules ?? this.rules,
    );
  }
}
