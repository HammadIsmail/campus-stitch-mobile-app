class VerificationModel {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String university;
  final String campusId;
  final String campusName;
  final String program;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String confidenceStatus; // 'matches' | 'mismatch'
  final String? cardPhotoUrl;
  final String? livePhotoUrl;
  final String createdAt;

  VerificationModel({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.university,
    required this.campusId,
    required this.campusName,
    this.program = '',
    this.status = 'pending',
    this.confidenceStatus = 'matches',
    this.cardPhotoUrl,
    this.livePhotoUrl,
    required this.createdAt,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? json['studentId']?.toString() ?? '',
      university: json['university']?.toString() ?? '',
      campusId: json['campus_id']?.toString() ?? json['campusId']?.toString() ?? '',
      campusName: json['campus_name']?.toString() ?? json['campusName']?.toString() ?? '',
      program: json['program']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      confidenceStatus: json['confidence_status']?.toString() ?? 'matches',
      cardPhotoUrl: json['card_photo_url']?.toString(),
      livePhotoUrl: json['live_photo_url']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
