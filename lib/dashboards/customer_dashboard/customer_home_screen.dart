import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:artist_hub/shared/constants/app_colors.dart';
import 'package:artist_hub/shared/preferences/shared_preferences.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  Map<String, bool> _likedPosts = {};
  Map<String, int> _postLikes = {};
  List<String> _userLikedMediaIds = []; // Store which posts user has liked

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _fetchUserLikedPosts(); // First fetch user's liked posts
    await _fetchPosts(); // Then fetch all posts
  }

  // Fetch posts that current user has liked
  Future<void> _fetchUserLikedPosts() async {
    final userId = SharedPreferencesHelper.userId;
    if (userId == null || userId.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('https://prakrutitech.xyz/gaurang/view_like.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['data'] != null) {
          final likedPosts = data['data'] as List;

          setState(() {
            _userLikedMediaIds = likedPosts
                .map<String>((post) => post['media_id']?.toString() ?? '')
                .where((id) => id.isNotEmpty)
                .toList();
          });

          debugPrint('User liked posts: ${_userLikedMediaIds.length}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching user liked posts: $e');
    }
  }

  // SIMPLE LIKE FUNCTION
  Future<void> _toggleLike(String mediaId) async {
    final userId = SharedPreferencesHelper.userId;
    if (userId == null || userId.isEmpty) {
      _showErrorSnackbar('Please login to like posts');
      return;
    }

    final isCurrentlyLiked = _likedPosts[mediaId] ?? false;
    final currentLikeCount = _postLikes[mediaId] ?? 0;

    // Update UI immediately
    setState(() {
      _likedPosts[mediaId] = !isCurrentlyLiked;
      _postLikes[mediaId] = isCurrentlyLiked
          ? currentLikeCount - 1
          : currentLikeCount + 1;

      // Also update local liked list
      if (isCurrentlyLiked) {
        _userLikedMediaIds.remove(mediaId);
      } else {
        _userLikedMediaIds.add(mediaId);
      }
    });

    try {
      final response = await http.post(
        Uri.parse('https://prakrutitech.xyz/gaurang/like.php'),
        body: {
          'user_id': userId,
          'media_id': mediaId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          final result = data['data'];
          final newLikeStatus = result['like_status']?.toString() ?? '';
          final newLikeCount = int.tryParse(result['total_likes']?.toString() ?? '0') ?? 0;

          setState(() {
            _likedPosts[mediaId] = newLikeStatus == 'liked';
            _postLikes[mediaId] = newLikeCount;
          });
        }
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _likedPosts[mediaId] = isCurrentlyLiked;
        _postLikes[mediaId] = currentLikeCount;
        if (isCurrentlyLiked) {
          _userLikedMediaIds.add(mediaId);
        } else {
          _userLikedMediaIds.remove(mediaId);
        }
      });
    }
  }

  // SIMPLE POST FETCHING - FIXED VERSION
  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://prakrutitech.xyz/gaurang/view_artist_media.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['data'] != null) {
          List<Map<String, dynamic>> posts = [];
          final postsData = data['data'] as List;

          for (var post in postsData) {
            String mediaId = post['id']?.toString() ?? '';

            // Get like count
            int likeCount = 0;
            if (post['like_count'] != null) {
              likeCount = int.tryParse(post['like_count'].toString()) ?? 0;
            }

            // Check if current user has liked this post
            bool isLikedByUser = _userLikedMediaIds.contains(mediaId);

            // Also check if API returns user_liked info
            if (post['user_liked'] != null) {
              isLikedByUser = post['user_liked'] == true || post['user_liked'] == '1';
            }

            posts.add({
              'id': mediaId,
              'artist_name': post['name']?.toString() ?? 'Artist',
              'profile_image': post['profile_image']?.toString() ?? '',
              'media_url': post['media_url']?.toString() ?? '',
              'media_type': post['media_type']?.toString() ?? 'image',
              'caption': post['caption']?.toString() ?? '',
              'like_count': likeCount,
              'created_at': post['created_at']?.toString() ?? DateTime.now().toString(),
            });

            // Initialize with correct like status
            _postLikes[mediaId] = likeCount;
            _likedPosts[mediaId] = isLikedByUser;
          }

          setState(() => _posts = posts);
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load posts');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Refresh both posts and liked posts
  Future<void> _refreshData() async {
    await _fetchUserLikedPosts();
    await _fetchPosts();
  }

  // SIMPLE POST ITEM WIDGET - FIXED
  Widget _buildPostItem(Map<String, dynamic> post) {
    final mediaId = post['id'];
    final isLiked = _likedPosts[mediaId] ?? false;
    final likeCount = _postLikes[mediaId] ?? 0;

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: post['profile_image'] != null && post['profile_image'].isNotEmpty
                  ? NetworkImage('https://prakrutitech.xyz/gaurang/${post['profile_image']}')
                  : null,
              child: post['profile_image'] == null || post['profile_image'].isEmpty
                  ? Icon(Icons.person, color: AppColors.primary)
                  : null,
            ),
            title: Text(
              post['artist_name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_formatDate(post['created_at'])),
          ),

          // Media
          if (post['media_url'] != null && post['media_url'].isNotEmpty)
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[100],
              child: post['media_type'] == 'video'
                  ? Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 60,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              )
                  : Image.network(
                'https://prakrutitech.xyz/gaurang/${post['media_url']}',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          // Caption
          if (post['caption'] != null && post['caption'].isNotEmpty)
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(post['caption']),
            ),

          // Like Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 18),
                SizedBox(width: 5),
                Text(
                  '$likeCount likes',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: () => _toggleLike(mediaId),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLiked ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey[600],
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          isLiked ? 'Liked' : 'Like',
                          style: TextStyle(
                            color: isLiked ? Colors.red : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Spacer(),

                // Share Button
                GestureDetector(
                  onTap: () => _sharePost(post),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 20, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Text(
                          'Share',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Share Function
  Future<void> _sharePost(Map<String, dynamic> post) async {
    await Share.share(
      'Check out this post by ${post['artist_name']} on Artist Hub!',
    );
  }

  // Date Format
  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';

      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  // Snackbars
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artist Hub'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshData, // Use _refreshData instead of _fetchPosts
        child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            return _buildPostItem(_posts[index]);
          },
        ),
      ),
    );
  }
}