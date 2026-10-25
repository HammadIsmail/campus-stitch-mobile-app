class CommentModel {
  final String id;
  final String postId;
  final String? parentCommentId;
  final String authorId;
  final String authorName;
  final String authorStudentId;
  final bool authorVerified;
  final String content;
  final int upvotes;
  final int score;
  final String createdAt;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.postId,
    this.parentCommentId,
    required this.authorId,
    required this.authorName,
    this.authorStudentId = '',
    this.authorVerified = true,
    required this.content,
    this.upvotes = 1,
    this.score = 1,
    required this.createdAt,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? json['postId']?.toString() ?? '',
      parentCommentId: json['parent_comment_id']?.toString() ?? json['parentCommentId']?.toString(),
      authorId: json['author_id']?.toString() ?? json['authorId']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? json['authorName']?.toString() ?? 'Student',
      authorStudentId: json['author_student_id']?.toString() ?? json['authorStudentId']?.toString() ?? '',
      authorVerified: json['author_verified'] == true || json['authorVerified'] == true,
      content: json['content']?.toString() ?? '',
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 1,
      score: (json['score'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      replies: const [],
    );
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? parentCommentId,
    String? authorId,
    String? authorName,
    String? authorStudentId,
    bool? authorVerified,
    String? content,
    int? upvotes,
    int? score,
    String? createdAt,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorStudentId: authorStudentId ?? this.authorStudentId,
      authorVerified: authorVerified ?? this.authorVerified,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }
}
