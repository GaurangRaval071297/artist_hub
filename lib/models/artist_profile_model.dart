class ArtistProfile {
  final String? id;
  final String userId;
  final String category;
  final String experience;
  final String price;
  final String description;
  final String artistName;
  final String artistEmail;
  final String? location;
  final String? skills;

  ArtistProfile({
    this.id,
    required this.userId,
    required this.category,
    required this.experience,
    required this.price,
    required this.description,
    required this.artistName,
    required this.artistEmail,
    this.location,
    this.skills,
  });

  factory ArtistProfile.fromJson(Map<String, dynamic> json) {
    return ArtistProfile(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      artistName: json['artist_name']?.toString() ?? '',
      artistEmail: json['artist_email']?.toString() ?? '',
      location: json['location']?.toString(),
      skills: json['skills']?.toString(),
    );
  }
}