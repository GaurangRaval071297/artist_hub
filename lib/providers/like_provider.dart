import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:artist_hub/shared/constants/api_urls.dart';
import 'package:artist_hub/models/like_model.dart';

class LikeProvider with ChangeNotifier {
  List<Like> _likes = [];
  bool _isLoading = false;

  List<Like> get likes => _likes;
  bool get isLoading => _isLoading;

  // Fetch likes for a specific post
  Future<void> fetchLikesForPost(String postId) async {
    if (postId.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}view_like.php?post_id=$postId'),
      );

      debugPrint('Fetching likes for post: $postId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          final List<dynamic> likesData = data['data'] ?? [];

          _likes = likesData.map((likeJson) {
            return Like.fromJson(likeJson);
          }).toList();

          debugPrint('Fetched ${_likes.length} likes');
        }
      }
    } catch (e) {
      debugPrint('Error fetching likes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add like to a post
  Future<Map<String, dynamic>> addLike(String postId, String userId, String userName) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}add_like.php'),
        body: {
          'post_id': postId,
          'user_id': userId,
          'user_name': userName,
        },
      );

      debugPrint('Add like response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          final newLike = Like(
            id: data['like_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            postId: postId,
            userId: userId,
            userName: userName,
            timestamp: DateTime.now().toString(),
          );

          _likes.add(newLike);
          notifyListeners();

          return {
            'success': true,
            'message': data['message'] ?? 'Liked successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to like',
          };
        }
      }
    } catch (e) {
      debugPrint('Error adding like: $e');
    }

    return {
      'success': false,
      'message': 'Network error occurred',
    };
  }

  // Remove like from a post
  Future<Map<String, dynamic>> removeLike(String postId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}remove_like.php'),
        body: {
          'post_id': postId,
          'user_id': userId,
        },
      );

      debugPrint('Remove like response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          _likes.removeWhere((like) =>
          like.postId == postId && like.userId == userId);
          notifyListeners();

          return {
            'success': true,
            'message': data['message'] ?? 'Unliked successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to unlike',
          };
        }
      }
    } catch (e) {
      debugPrint('Error removing like: $e');
    }

    return {
      'success': false,
      'message': 'Network error occurred',
    };
  }

  // Check if user liked a post
  bool hasUserLiked(String postId, String userId) {
    return _likes.any((like) =>
    like.postId == postId && like.userId == userId);
  }

  void clearLikes() {
    _likes.clear();
    notifyListeners();
  }
}