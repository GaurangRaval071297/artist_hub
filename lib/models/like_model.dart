class Like {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String timestamp;

  Like({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      timestamp: json['created_at'] ?? DateTime.now().toString(),
    );
  }
}