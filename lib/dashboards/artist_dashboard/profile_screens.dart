import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artist_hub/providers/auth_provider.dart';
import 'package:artist_hub/providers/post_provider.dart';
import 'package:artist_hub/shared/constants/app_colors.dart';
import 'package:artist_hub/shared/constants/custom_dialog.dart';
import 'package:artist_hub/shared/preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'add_post_screens.dart';

class ProfileScreens extends StatefulWidget {
  final String userId;

  const ProfileScreens({required this.userId, super.key});

  @override
  State<ProfileScreens> createState() => _ProfileScreensState();
}

class _ProfileScreensState extends State<ProfileScreens> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  // Followers and Following counts removed

  @override
  void initState() {
    super.initState();
    _loadDataFromSharedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchArtistPosts();
    });
  }

  void _loadDataFromSharedPreferences() async {
    String phone = SharedPreferencesHelper.userPhone;
    String address = SharedPreferencesHelper.userAddress;

    if (phone.isEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      phone = authProvider.userPhone;
    }

    if (address.isEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      address = authProvider.userAddress;
    }

    setState(() {
      _phoneController.text = phone;
      _addressController.text = address;
    });
  }

  _fetchArtistPosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userId.isNotEmpty) {
      await postProvider.fetchArtistPosts(authProvider.userId);
    }
  }

  Future<void> _saveToSharedPreferences() async {
    await SharedPreferencesHelper.setUserPhone(_phoneController.text.trim());
    await SharedPreferencesHelper.setUserAddress(
      _addressController.text.trim(),
    );
  }

  void showAlert(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomAlertDialog(
        title: title,
        message: message,
        icon: isSuccess
            ? Icons.check_circle_outline
            : Icons.warning_amber_rounded,
        isSuccess: isSuccess,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _saveToSharedPreferences();
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.updateProfile(
          userPhone: _phoneController.text.trim(),
          userAddress: _addressController.text.trim(),
        );

        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        showAlert('Success', 'Profile updated successfully!', isSuccess: true);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        showAlert('Error', 'Failed to save profile: $e');
      }
    }
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  // Get likes for a post
  Future<Map<String, dynamic>> getLikesForPost(String postId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://prakrutitech.xyz/gaurang/view_like.php?post_id=$postId',
        ),
      );

      debugPrint('View Likes API Response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error getting likes: $e');
    }

    return {'status': false, 'data': [], 'message': 'Network error'};
  }

  // Toggle like for a post
  Future<Map<String, dynamic>> toggleLike(String postId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('https://prakrutitech.xyz/gaurang/like.php'),
        body: {'post_id': postId, 'user_id': userId},
      );

      debugPrint('Toggle Like API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': data['status'] ?? false,
          'message': data['message'] ?? 'Operation completed',
          'like_count': data['like_count'] ?? 0,
        };
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }

    return {'status': false, 'message': 'Network error'};
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: AppColors.appBarGradient.colors[0],
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.grid_on, size: 28, color: AppColors.white)),
              Tab(
                icon: Icon(Icons.person_pin, size: 28, color: AppColors.white),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.appBarGradient.colors[0],
                  ),
                )
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: _buildProfileHeader(authProvider, postProvider),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      _buildPostsGridSection(postProvider, authProvider),
                      _buildProfileInfoSection(authProvider),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    AuthProvider authProvider,
    PostProvider postProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.appBarGradient.colors[0],
            AppColors.appBarGradient.colors[1],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.appBarGradient.colors[0],
                ),
              ),

              SizedBox(width: 20),

              // Only Posts count is shown, followers and following removed
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Centered the posts count
                  children: [
                    _buildStatColumn(
                      count: postProvider.posts.length.toString(),
                      label: 'Posts',
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authProvider.userName.isNotEmpty
                    ? authProvider.userName
                    : 'Artist Name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                authProvider.userType == 'artist'
                    ? 'Professional Artist'
                    : 'Customer',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ID: ${authProvider.userId}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({required String count, required String label}) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPostsGridSection(
    PostProvider postProvider,
    AuthProvider authProvider,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchArtistPosts();
      },
      child: postProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.appBarGradient.colors[0],
              ),
            )
          : postProvider.posts.isEmpty
          ? _buildNoPostsView()
          : GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                childAspectRatio: 1,
              ),
              itemCount: postProvider.posts.length,
              itemBuilder: (context, index) {
                final post = postProvider.posts[index];
                return _buildPostGridItem(post, authProvider);
              },
            ),
    );
  }

  Widget _buildNoPostsView() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: Icon(
                Icons.photo_camera,
                size: 50,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No Posts Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'When you share posts, they will appear here.',
              style: TextStyle(color: Colors.grey[500]),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPostScreens()),
                ).then((_) {
                  _fetchArtistPosts();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appBarGradient.colors[0],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text('Share Your First Post'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostGridItem(Post post, AuthProvider authProvider) {
    return GestureDetector(
      onTap: () {
        _showPostDetail(post, authProvider);
      },
      child: Container(
        color: Colors.grey[900],
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMediaWidget(post),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),

            Positioned(
              bottom: 8,
              left: 8,
              child: Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    post.likeCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (post.mediaType == 'video')
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.videocam, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaWidget(Post post) {
    if (post.mediaUrl.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 40, color: Colors.grey[500]),
              SizedBox(height: 8),
              Text(
                'No Image',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (post.mediaUrl.startsWith('http')) {
      return Image.network(
        post.mediaUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image error: $error for URL: ${post.mediaUrl}');
          return Container(
            color: Colors.grey[800],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 40, color: Colors.grey[500]),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      try {
        return Image.file(
          File(post.mediaUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: Center(child: Icon(Icons.image, color: Colors.grey[500])),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey[800],
          child: Center(child: Icon(Icons.image, color: Colors.grey[500])),
        );
      }
    }
  }

  void _showPostDetail(Post post, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool localIsLiked = post.isLiked;
            int localLikeCount = post.likeCount;

            void handleLike() async {
              final postProvider = Provider.of<PostProvider>(
                context,
                listen: false,
              );

              // Optimistically update UI
              final wasLiked = localIsLiked;
              final oldLikeCount = localLikeCount;

              setState(() {
                localIsLiked = !localIsLiked;
                localLikeCount = localIsLiked
                    ? localLikeCount + 1
                    : localLikeCount - 1;
              });

              // Update in provider
              postProvider.updatePostLike(
                post.id,
                localLikeCount,
                localIsLiked,
                localIsLiked
                    ? [...post.likedByUsers, authProvider.userId]
                    : post.likedByUsers
                          .where((id) => id != authProvider.userId)
                          .toList(),
              );

              // Call API
              final result = await toggleLike(post.id, authProvider.userId);

              if (result['status'] == false) {
                // Revert if API fails
                setState(() {
                  localIsLiked = wasLiked;
                  localLikeCount = oldLikeCount;
                });

                postProvider.updatePostLike(
                  post.id,
                  oldLikeCount,
                  wasLiked,
                  wasLiked
                      ? [...post.likedByUsers, authProvider.userId]
                      : post.likedByUsers
                            .where((id) => id != authProvider.userId)
                            .toList(),
                );

                // Show error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Failed to update like'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Post Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            color: Colors.black,
                            child: post.mediaType == 'video'
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Video Content',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  )
                                : post.mediaUrl.startsWith('http')
                                ? Image.network(
                                    post.mediaUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.broken_image,
                                                size: 60,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Image not available',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : post.mediaUrl.isNotEmpty
                                ? Image.file(
                                    File(post.mediaUrl),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.blue[100],
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.artistName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          _formatDate(post.timestamp),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                Text(
                                  post.caption.isNotEmpty
                                      ? post.caption
                                      : 'No caption',
                                  style: TextStyle(fontSize: 16, height: 1.5),
                                ),

                                SizedBox(height: 20),

                                Row(
                                  children: [
                                    // Like Button
                                    GestureDetector(
                                      onTap: handleLike,
                                      child: Row(
                                        children: [
                                          Icon(
                                            localIsLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: 24,
                                            color: localIsLiked
                                                ? Colors.red
                                                : Colors.grey[600],
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            localLikeCount.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 20),

                                    // Comment Button
                                    GestureDetector(
                                      onTap: () {
                                        // Add comment functionality here
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.comment_outlined,
                                            size: 20,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            '56',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 20),

                                    // Share Button
                                    GestureDetector(
                                      onTap: () {
                                        // Add share functionality here
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.share_outlined,
                                            size: 20,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            '12',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Spacer(),

                                    // View Likes Button
                                    if (localLikeCount > 0)
                                      TextButton(
                                        onPressed: () {
                                          _showLikesDialog(post.id);
                                        },
                                        child: Text(
                                          'View ${localLikeCount} ${localLikeCount == 1 ? 'like' : 'likes'}',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLikesDialog(String postId) async {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: getLikesForPost(postId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text('Likes'),
                content: Center(child: CircularProgressIndicator()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ],
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return AlertDialog(
                title: Text('Likes'),
                content: Text('Failed to load likes'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ],
              );
            }

            final data = snapshot.data as Map<String, dynamic>;

            if (data['status'] != true) {
              return AlertDialog(
                title: Text('Likes'),
                content: Text(data['message'] ?? 'No likes yet'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ],
              );
            }

            final List<dynamic> likesList = data['data'] ?? [];

            return AlertDialog(
              title: Text('Likes (${likesList.length})'),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: likesList.isEmpty
                    ? Center(child: Text('No likes yet'))
                    : ListView.builder(
                        itemCount: likesList.length,
                        itemBuilder: (context, index) {
                          final like = likesList[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Icon(Icons.person, color: Colors.blue),
                            ),
                            title: Text(like['user_name'] ?? 'User'),
                            subtitle: Text(
                              _formatDate(
                                like['created_at'] ?? DateTime.now().toString(),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileInfoSection(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 15),

            _buildDetailRow(
              icon: Icons.email_outlined,
              label: 'Email Address',
              value: authProvider.userEmail.isNotEmpty
                  ? authProvider.userEmail
                  : 'Not set',
              isEditable: false,
            ),
            SizedBox(height: 15),

            _buildPhoneField(),
            SizedBox(height: 15),

            _buildAddressField(),
            SizedBox(height: 15),

            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'Account Type',
              value: authProvider.userType.isNotEmpty
                  ? authProvider.userType.toUpperCase()
                  : 'Not set',
              isEditable: false,
            ),

            if (_isEditing) ...[
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 20),
                      SizedBox(width: 10),
                      Text('Save Changes', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _loadDataFromSharedPreferences();
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ],

            if (!_isEditing) ...[
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.appBarGradient.colors[0],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 10),
                      Text('Edit Profile', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = false,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.appBarGradient.colors[0].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: AppColors.appBarGradient.colors[0],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: isEditable ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.appBarGradient.colors[0].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone_outlined,
                  size: 22,
                  color: AppColors.appBarGradient.colors[0],
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    _isEditing
                        ? TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: 'Enter 10-digit phone number',
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (!_isValidPhone(value)) {
                                return 'Enter valid 10-digit phone number';
                              }
                              return null;
                            },
                          )
                        : Text(
                            _phoneController.text.isNotEmpty
                                ? _formatPhoneNumber(_phoneController.text)
                                : 'Not set',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.appBarGradient.colors[0].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 22,
                  color: AppColors.appBarGradient.colors[0],
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    _isEditing
                        ? TextFormField(
                            controller: _addressController,
                            keyboardType: TextInputType.streetAddress,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter your complete address',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Address is required';
                              }
                              if (value.length < 10) {
                                return 'Enter complete address';
                              }
                              return null;
                            },
                          )
                        : Text(
                            _addressController.text.isNotEmpty
                                ? _addressController.text
                                : 'Not set',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;

    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
    }

    return phone;
  }
}
