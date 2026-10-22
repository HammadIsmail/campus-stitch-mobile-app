class PostModel {
  final String id;
  final String communityName;
  final String title;
  final String content;
  final String flair;
  final String authorName;
  final String authorStudentId;
  final String campusId;
  final String? imageUrl;
  final String? linkUrl;
  final int upvotes;
  final int downvotes;
  final int score;
  final int commentsCount;
  final String createdAt;
  final int userVote; // 1 (upvoted), -1 (downvoted), 0 (none)

  PostModel({
    required this.id,
    required this.communityName,
    required this.title,
    required this.content,
    this.flair = 'Discussion',
    required this.authorName,
    this.authorStudentId = '',
    this.campusId = '',
    this.imageUrl,
    this.linkUrl,
    this.upvotes = 1,
    this.downvotes = 0,
    this.score = 1,
    this.commentsCount = 0,
    required this.createdAt,
    this.userVote = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? '',
      communityName: json['community_name']?.toString() ?? json['communityName']?.toString() ?? 'r/general',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      flair: json['flair']?.toString() ?? 'Discussion',
      authorName: json['author_name']?.toString() ?? json['authorName']?.toString() ?? 'Student',
      authorStudentId: json['author_student_id']?.toString() ?? json['authorStudentId']?.toString() ?? '',
      campusId: json['campus_id']?.toString() ?? json['campusId']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      linkUrl: json['link_url']?.toString() ?? json['linkUrl']?.toString(),
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 1,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 1,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? (json['commentsCount'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      userVote: (json['userVote'] as num?)?.toInt() ?? 0,
    );
  }

  PostModel copyWith({
    int? upvotes,
    int? downvotes,
    int? score,
    int? userVote,
  }) {
    return PostModel(
      id: id,
      communityName: communityName,
      title: title,
      content: content,
      flair: flair,
      authorName: authorName,
      authorStudentId: authorStudentId,
      campusId: campusId,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      score: score ?? this.score,
      commentsCount: commentsCount,
      createdAt: createdAt,
      userVote: userVote ?? this.userVote,
    );
  }
}
