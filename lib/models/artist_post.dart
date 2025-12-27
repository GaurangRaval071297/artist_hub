
class ArtistPost {
final String id;
final String mediaUrl;
final String mediaType;
final String caption;
final String timestamp;
final String artistId;
final String artistName;
final int likeCount;
final int commentCount;

ArtistPost({
required this.id,
required this.mediaUrl,
required this.mediaType,
required this.caption,
required this.timestamp,
required this.artistId,
required this.artistName,
required this.likeCount,
required this.commentCount,
});

factory ArtistPost.fromJson(Map<String, dynamic> json) {
String mediaUrl = json['media_url'] ?? '';

if (mediaUrl.isNotEmpty && !mediaUrl.startsWith('http')) {
if (mediaUrl.startsWith('/')) {
mediaUrl = mediaUrl.substring(1);
}
mediaUrl = 'https://prakrutitech.xyz/gaurang/$mediaUrl';
}

return ArtistPost(
id: json['id']?.toString() ?? '',
mediaUrl: mediaUrl,
mediaType: json['media_type'] ?? 'image',
caption: json['caption'] ?? '',
timestamp: json['created_at'] ?? DateTime.now().toString(),
artistId: json['artist_id']?.toString() ?? '',
artistName: json['artist_name'] ?? 'Artist',
likeCount: (json['like_count'] ?? 0) as int,
commentCount: (json['comment_count'] ?? 0) as int,
);
}
}