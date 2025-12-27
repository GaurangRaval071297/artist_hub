
class Post {
  final String id;
  final String mediaUrl;
  final String mediaType;
  final String caption;
  final String timestamp;
  final String artistId;
  final String artistName;

  Post({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.timestamp,
    required this.artistId,
    required this.artistName,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      caption: json['caption'] ?? '',
      timestamp: json['created_at'] ?? DateTime.now().toString(),
      artistId: json['artist_id']?.toString() ?? '',
      artistName: json['artist_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'caption': caption,
      'timestamp': timestamp,
      'artist_id': artistId,
      'artist_name': artistName,
    };
  }
}