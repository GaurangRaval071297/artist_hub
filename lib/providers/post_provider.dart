// providers/post_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:artist_hub/shared/constants/api_urls.dart';

import '../dashboards/artist_dashboard/add_post_screens.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // post_provider.dart માં fetchArtistPosts method update કરો
  Future<void> fetchArtistPosts(String artistId) async {
    if (artistId.isEmpty) {
      debugPrint('❌ Artist ID is empty');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final apiUrl = 'https://prakrutitech.xyz/gaurang/view_artist_media_by_id.php?artist_id=$artistId';
      debugPrint('📡 Fetching posts from: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Full Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ API Status: ${data['status']}');
        debugPrint('📋 API Message: ${data['message']}');

        if (data['status'] == true) {
          final List<dynamic> postsData = data['data'] ?? [];
          debugPrint('📸 Found ${postsData.length} posts');

          // Debug each post
          for (var post in postsData) {
            debugPrint('🖼️ Post Data: ID: ${post['id']}, Media: ${post['media_url']}, Caption: ${post['caption']}');
          }

          _posts = postsData.map((postJson) {
            String mediaUrl = postJson['media_url'] ?? '';
            debugPrint('🔗 Original Media URL: $mediaUrl');

            // Fix URL if needed
            if (mediaUrl.isNotEmpty && !mediaUrl.startsWith('http')) {
              // Remove leading slash if present
              if (mediaUrl.startsWith('/')) {
                mediaUrl = mediaUrl.substring(1);
              }
              // Add base URL
              mediaUrl = 'https://prakrutitech.xyz/gaurang/$mediaUrl';
              debugPrint('🔗 Fixed Media URL: $mediaUrl');
            }

            return Post(
              id: postJson['id']?.toString() ?? '',
              mediaUrl: mediaUrl,
              mediaType: postJson['media_type'] ?? 'image',
              caption: postJson['caption'] ?? '',
              timestamp: postJson['created_at'] ?? DateTime.now().toString(),
              artistId: postJson['artist_id']?.toString() ?? '',
              artistName: postJson['artist_name'] ?? '',
              likeCount: (postJson['like_count'] ?? 0) as int,
              isLiked: (postJson['is_liked'] ?? false) as bool,
            );
          }).toList();

          debugPrint('✅ Successfully loaded ${_posts.length} posts');
        } else {
          debugPrint('❌ API returned false status: ${data['message']}');
          // Show empty state
          _posts = [];
        }
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        _posts = [];
      }
    } catch (e) {
      debugPrint('💥 Error fetching posts: $e');
      _posts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch likes for a specific post
  Future<Map<String, dynamic>> _fetchLikesForPost(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}view_like.php?post_id=$postId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          final List<dynamic> likesList = data['data'] ?? [];
          final likedByUsers = likesList.map((like) => like['user_id']?.toString() ?? '').toList();

          return {
            'like_count': likesList.length,
            'liked_by_users': likedByUsers,
            'is_liked': false, // We'll update this based on current user
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching likes for post $postId: $e');
    }

    return {
      'like_count': 0,
      'liked_by_users': [],
      'is_liked': false,
    };
  }

  // Toggle like for a post
  Future<void> toggleLike(String postId, String userId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);

    if (postIndex != -1) {
      final post = _posts[postIndex];
      final isCurrentlyLiked = post.isLiked;
      final currentLikedByUsers = List<String>.from(post.likedByUsers);

      // Update UI immediately for better UX
      if (isCurrentlyLiked) {
        // Remove like
        currentLikedByUsers.remove(userId);
        _posts[postIndex] = post.copyWith(
          likeCount: post.likeCount - 1,
          isLiked: false,
          likedByUsers: currentLikedByUsers,
        );
      } else {
        // Add like
        currentLikedByUsers.add(userId);
        _posts[postIndex] = post.copyWith(
          likeCount: post.likeCount + 1,
          isLiked: true,
          likedByUsers: currentLikedByUsers,
        );
      }
      notifyListeners();

      // Call API
      try {
        final response = await http.post(
          Uri.parse('${ApiUrls.baseUrl}like.php'),
          body: {
            'post_id': postId,
            'user_id': userId,
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == false) {
            // Revert if API fails
            if (isCurrentlyLiked) {
              currentLikedByUsers.add(userId);
              _posts[postIndex] = post.copyWith(
                likeCount: post.likeCount,
                isLiked: true,
                likedByUsers: currentLikedByUsers,
              );
            } else {
              currentLikedByUsers.remove(userId);
              _posts[postIndex] = post.copyWith(
                likeCount: post.likeCount,
                isLiked: false,
                likedByUsers: currentLikedByUsers,
              );
            }
            notifyListeners();

            // Show error
            debugPrint('Like API failed: ${data['message']}');
          } else {
            debugPrint('Like toggled successfully: ${data['message']}');
          }
        }
      } catch (e) {
        debugPrint('Error toggling like: $e');

        // Revert on network error
        if (isCurrentlyLiked) {
          currentLikedByUsers.add(userId);
          _posts[postIndex] = post.copyWith(
            likeCount: post.likeCount,
            isLiked: true,
            likedByUsers: currentLikedByUsers,
          );
        } else {
          currentLikedByUsers.remove(userId);
          _posts[postIndex] = post.copyWith(
            likeCount: post.likeCount,
            isLiked: false,
            likedByUsers: currentLikedByUsers,
          );
        }
        notifyListeners();
      }
    }
  }

  // Update post like status
  void updatePostLike(String postId, int newLikeCount, bool isLiked, List<String> likedByUsers) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);

    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = post.copyWith(
        likeCount: newLikeCount,
        isLiked: isLiked,
        likedByUsers: likedByUsers,
      );
      notifyListeners();
      debugPrint('👍 Updated post $postId: likeCount=$newLikeCount, isLiked=$isLiked');
    }
  }

  void addPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }
}