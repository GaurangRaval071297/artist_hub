import 'dart:convert';
import 'dart:io';
import 'package:artist_hub/shared/Constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artist_hub/providers/auth_provider.dart';
import 'package:artist_hub/providers/post_provider.dart';
import 'package:artist_hub/shared/constants/api_urls.dart';
import 'package:artist_hub/shared/constants/app_messages.dart';
import 'package:artist_hub/shared/constants/custom_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddPostScreens extends StatefulWidget {
  final String? artistId;
  const AddPostScreens({this.artistId, super.key});

  @override
  State<AddPostScreens> createState() => _AddPostScreensState();
}

class _AddPostScreensState extends State<AddPostScreens> {
  final ImagePicker _picker = ImagePicker();
  File? selectedMedia;
  bool isVideo = false;
  final TextEditingController captionController = TextEditingController();

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

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedMedia = File(image.path);
        isVideo = false;
      });
    }
  }

  Future<void> pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        selectedMedia = File(video.path);
        isVideo = true;
      });
    }
  }

  Future<void> addPostAPI() async {
    if (selectedMedia == null) {
      showAlert(
        AppMessages.titleWarning,
        AppMessages.validateImage,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    postProvider.setLoading(true);

    try {
      final uri = Uri.parse(ApiUrls.addArtistMediaUrl);
      debugPrint('Uploading to: ${ApiUrls.addArtistMediaUrl}');

      var request = http.MultipartRequest('POST', uri);

      final artistId = widget.artistId ?? authProvider.userId;

      if (artistId.isEmpty) {
        showAlert('Error', 'Artist ID not found. Please login again.');
        postProvider.setLoading(false);
        return;
      }

      debugPrint('Artist ID: $artistId');
      debugPrint('Media Type: ${isVideo ? "video" : "image"}');
      debugPrint('Caption: ${captionController.text.trim()}');

      request.fields['artist_id'] = artistId;
      request.fields['media_type'] = isVideo ? "video" : "image";
      request.fields['caption'] = captionController.text.trim();

      request.files.add(
        await http.MultipartFile.fromPath(
          'media',
          selectedMedia!.path,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("RESPONSE: $responseBody");

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);

        if (responseData['status'] == true) {
          // Get media URL from response or construct it
          String mediaUrl = responseData['media_url'] ?? '';
          if (mediaUrl.isEmpty && responseData['post_id'] != null) {
            // Construct URL if not provided
            mediaUrl = '${ApiUrls.baseUrl}uploads/posts/${responseData['post_id']}.jpg';
          }

          // Add post to Provider
          final newPost = Post(
            id: responseData['post_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            mediaUrl: mediaUrl,
            mediaType: isVideo ? "video" : "image",
            caption: captionController.text.trim(),
            timestamp: DateTime.now().toString(),
            artistId: artistId,
            artistName: authProvider.userName,
            likeCount: 0,
            isLiked: false,
          );

          postProvider.addPost(newPost);

          showAlert(
            AppMessages.titleSuccess,
            responseData['message'] ?? AppMessages.successInsert,
            isSuccess: true,
          );

          setState(() {
            selectedMedia = null;
            captionController.clear();
          });

          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          showAlert(
            AppMessages.titleError,
            responseData['message'] ?? AppMessages.errorInsert,
          );
        }
      } else {
        showAlert(
          AppMessages.titleError,
          'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      showAlert(
        AppMessages.titleError,
        AppMessages.errorSomethingWentWrong,
      );
    }

    postProvider.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Post"),
        centerTitle: true,
        backgroundColor: AppColors.appBarGradient.colors[0],
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.userName.isNotEmpty
                            ? authProvider.userName
                            : 'Artist',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Artist ID: ${authProvider.userId}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Media Preview
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: selectedMedia == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.image, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No Image / Video Selected",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
                  : isVideo
                  ? Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.videocam,
                      size: 80,
                      color: Colors.black54,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'VIDEO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  selectedMedia!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Pick Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Add Image"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: AppColors.appBarGradient.colors[0],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text("Add Video"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: AppColors.appBarGradient.colors[1],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Caption
            const Text(
              "Caption",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: captionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write a caption...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 30),

            // Post Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: postProvider.isLoading ? null : addPostAPI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child: postProvider.isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text(
                      "Post",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// models/post_model.dart
class Post {
  final String id;
  final String mediaUrl;
  final String mediaType;
  final String caption;
  final String timestamp;
  final String artistId;
  final String artistName;
  final int likeCount;
  final bool isLiked;
  final List<String> likedByUsers; // List of user IDs who liked

  Post({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.timestamp,
    required this.artistId,
    required this.artistName,
    this.likeCount = 0,
    this.isLiked = false,
    this.likedByUsers = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String mediaUrl = json['media_url'] ?? '';
    if (mediaUrl.isNotEmpty && !mediaUrl.startsWith('http')) {
      mediaUrl = 'https://prakrutitech.xyz/gaurang/$mediaUrl';
    }

    // Parse liked_by_users if available
    List<String> likedByUsers = [];
    if (json['liked_by_users'] is String) {
      likedByUsers = json['liked_by_users'].split(',').where((id) => id.isNotEmpty).toList();
    } else if (json['liked_by_users'] is List) {
      likedByUsers = List<String>.from(json['liked_by_users']);
    }

    return Post(
      id: json['id']?.toString() ?? '',
      mediaUrl: mediaUrl,
      mediaType: json['media_type'] ?? 'image',
      caption: json['caption'] ?? '',
      timestamp: json['created_at'] ?? DateTime.now().toString(),
      artistId: json['artist_id']?.toString() ?? '',
      artistName: json['artist_name'] ?? '',
      likeCount: (json['like_count'] ?? likedByUsers.length) as int,
      isLiked: (json['is_liked'] ?? false) as bool,
      likedByUsers: likedByUsers,
    );
  }

  Post copyWith({
    int? likeCount,
    bool? isLiked,
    List<String>? likedByUsers,
  }) {
    return Post(
      id: id,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      caption: caption,
      timestamp: timestamp,
      artistId: artistId,
      artistName: artistName,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      likedByUsers: likedByUsers ?? this.likedByUsers,
    );
  }
}