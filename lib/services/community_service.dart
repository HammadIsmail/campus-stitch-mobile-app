import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/comment_model.dart';
import '../models/community_model.dart';
import '../models/post_model.dart';

class CommunityService {
  static Future<List<PostModel>> getPosts({
    String? campusId,
    String? community,
    String sort = 'hot',
    String? query,
    String? flair,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, String>{};
    if (campusId != null && campusId.isNotEmpty) {
      params['campusId'] = campusId;
    }
    if (community != null && community.isNotEmpty && community != 'all') {
      params['community'] = community;
    }
    params['sort'] = sort;
    if (query != null && query.trim().isNotEmpty) {
      params['query'] = query.trim();
    }
    params['page'] = page.toString();
    params['limit'] = limit.toString();

    final queryString = Uri(queryParameters: params).query;
    final url = '${ApiConstants.communityPosts}?$queryString';

    final res = await ApiClient.get(url);
    if (res.success && res.data is Map) {
      final list = (res.data as Map)['posts'];
      if (list is List) {
        var posts = list
            .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        if (flair != null && flair.isNotEmpty && flair != 'All Flairs') {
          posts = posts
              .where((p) => p.flair.toLowerCase() == flair.toLowerCase())
              .toList();
        }
        return posts;
      }
    }
    return [];
  }

  static Future<ApiResponse> createPost({
    required String communityName,
    required String title,
    required String content,
    String flair = 'Discussion',
    String? imageUrl,
    String? linkUrl,
    String? campusId,
    String? universityId,
    String? authorName,
    String? authorStudentId,
  }) async {
    return await ApiClient.post(
      ApiConstants.communityPosts,
      body: {
        'communityName': communityName,
        'title': title.trim(),
        'content': content.trim(),
        'flair': flair,
        'imageUrl': imageUrl,
        'linkUrl': linkUrl,
        'campusId': campusId,
        'universityId': universityId,
        'authorName': authorName ?? 'Student',
        'authorStudentId': authorStudentId ?? '',
      },
    );
  }

  static Future<ApiResponse> votePost({
    required String postId,
    required int direction, // 1 (upvote), -1 (downvote), 0 (cancel)
    required String userId,
  }) async {
    String voteType = 'cancel';
    if (direction == 1) voteType = 'upvote';
    if (direction == -1) voteType = 'downvote';

    return await ApiClient.post(
      ApiConstants.communityVote,
      body: {
        'postId': postId,
        'voteType': voteType,
        'userId': userId,
      },
    );
  }

  static Future<bool> updatePost({
    required String postId,
    required String title,
    required String content,
    String? flair,
  }) async {
    try {
      final body = <String, dynamic>{
        'id': postId,
        'title': title.trim(),
        'content': content.trim(),
      };
      if (flair != null) body['flair'] = flair;
      final res = await ApiClient.patch(
        ApiConstants.communityPosts,
        body: body,
      );
      return res.success;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deletePost(String postId) async {
    try {
      final res = await ApiClient.delete('${ApiConstants.communityPosts}?id=$postId');
      return res.success;
    } catch (_) {
      return false;
    }
  }

  // Communities API
  static Future<List<CommunityModel>> getCommunities({bool all = true}) async {
    try {
      final res = await ApiClient.get('${ApiConstants.communityList}?all=${all ? 'true' : 'false'}');
      if (res.success && res.data is Map) {
        final list = (res.data as Map)['communities'];
        if (list is List) {
          return list
              .map((item) => CommunityModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      // Return empty on error
    }
    return [];
  }

  static Future<ApiResponse> createCommunity({
    required String name,
    required String title,
    String description = '',
    String category = 'General',
  }) async {
    return await ApiClient.post(
      ApiConstants.communityList,
      body: {
        'name': name.trim(),
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
      },
    );
  }

  static Future<ApiResponse> joinCommunity({
    required String communityId,
    required String userId,
  }) async {
    return await ApiClient.post(
      ApiConstants.communityJoin,
      body: {
        'communityId': communityId,
        'userId': userId,
      },
    );
  }

  // Comments & Replies API
  static Future<List<CommentModel>> getComments(String postId) async {
    try {
      final res = await ApiClient.get('${ApiConstants.communityComments}?postId=$postId');
      if (res.success && res.data is Map) {
        final list = (res.data as Map)['comments'];
        if (list is List) {
          final allComments = list
              .map((item) => CommentModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          // Organize into top-level and nested replies
          final topLevel = allComments.where((c) => c.parentCommentId == null || c.parentCommentId!.isEmpty).toList();
          final replies = allComments.where((c) => c.parentCommentId != null && c.parentCommentId!.isNotEmpty).toList();

          return topLevel.map((parent) {
            final childReplies = replies.where((r) => r.parentCommentId == parent.id).toList();
            return parent.copyWith(replies: childReplies);
          }).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<ApiResponse> addComment({
    required String postId,
    String? parentCommentId,
    required String content,
    String? authorName,
    String? authorStudentId,
    String? authorId,
  }) async {
    return await ApiClient.post(
      ApiConstants.communityComments,
      body: {
        'postId': postId,
        'parentCommentId': parentCommentId,
        'content': content.trim(),
        'authorName': authorName ?? 'Student',
        'authorStudentId': authorStudentId ?? '',
        'authorId': authorId ?? 'u_student',
      },
    );
  }
}
