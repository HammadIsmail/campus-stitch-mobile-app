class UserModel {
  final String userId;
  final String email;
  final String name;
  final String studentId;
  final String role; // 'student' | 'campus_admin' | 'super_admin'
  final String universityId;
  final String universityName;
  final String campusId;
  final String campusName;
  final bool isVerified;
  final String? avatarUrl;
  final String? program;
  final String? bio;
  final String? phone;
  final String? department;
  final String? hostelBlock;

  String get id => userId;
  String get fullName => name;
  String get university => universityName;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    this.studentId = '',
    this.role = 'student',
    this.universityId = '',
    this.universityName = '',
    this.campusId = '',
    this.campusName = '',
    this.isVerified = false,
    this.avatarUrl,
    this.program,
    this.bio,
    this.phone,
    this.department,
    this.hostelBlock,
  });

  bool get isSuperAdmin => role == 'super_admin';
  bool get isCampusAdmin => role == 'campus_admin' || role == 'super_admin';

  UserModel copyWith({
    String? userId,
    String? email,
    String? name,
    String? studentId,
    String? role,
    String? universityId,
    String? universityName,
    String? campusId,
    String? campusName,
    bool? isVerified,
    String? avatarUrl,
    String? program,
    String? bio,
    String? phone,
    String? fullName,
    String? department,
    String? hostelBlock,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: fullName ?? name ?? this.name,
      studentId: studentId ?? this.studentId,
      role: role ?? this.role,
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      campusId: campusId ?? this.campusId,
      campusName: campusName ?? this.campusName,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      program: program ?? this.program,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      hostelBlock: hostelBlock ?? this.hostelBlock,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? 'Student',
      studentId: json['studentId']?.toString() ?? json['student_id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      universityId: json['universityId']?.toString() ?? json['university_id']?.toString() ?? '',
      universityName: json['universityName']?.toString() ?? json['university']?.toString() ?? '',
      campusId: json['campusId']?.toString() ?? json['campus_id']?.toString() ?? '',
      campusName: json['campusName']?.toString() ?? json['campus_name']?.toString() ?? '',
      isVerified: json['isVerified'] == true || json['is_verified'] == true,
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
      program: json['program']?.toString(),
      bio: json['bio']?.toString(),
      phone: json['phone']?.toString(),
      department: json['department']?.toString(),
      hostelBlock: json['hostel_block']?.toString() ?? json['hostelBlock']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'studentId': studentId,
      'role': role,
      'universityId': universityId,
      'universityName': universityName,
      'campusId': campusId,
      'campusName': campusName,
      'isVerified': isVerified,
      'avatarUrl': avatarUrl,
      'program': program,
      'bio': bio,
      'phone': phone,
      'department': department,
      'hostelBlock': hostelBlock,
    };
  }
}
