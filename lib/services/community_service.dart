import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/post_model.dart';

class CommunityService {
  static Future<List<PostModel>> getPosts({
    String? campusId,
    String? community,
    String sort = 'hot',
    String? query,
    int page = 1,
    int limit = 3,
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
        return list.map((item) => PostModel.fromJson(Map<String, dynamic>.from(item))).toList();
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
    required int direction, // 1 (upvote), -1 (downvote)
    required String userId,
  }) async {
    return await ApiClient.post(
      ApiConstants.communityVote,
      body: {
        'postId': postId,
        'voteType': direction == 1 ? 'upvote' : 'downvote',
        'userId': userId,
      },
    );
  }
}
