
class Artist {
final String id;
final String name;
final String email;
final String phone;
final String address;
final String profilePic;
final String category;
final String experience;
final double rating;
final String hourlyRate;
final String description;

Artist({
required this.id,
required this.name,
required this.email,
required this.phone,
required this.address,
required this.profilePic,
required this.category,
required this.experience,
required this.rating,
required this.hourlyRate,
required this.description,
});

factory Artist.fromJson(Map<String, dynamic> json) {
return Artist(
id: json['id']?.toString() ?? '',
name: json['name'] ?? 'Artist',
email: json['email'] ?? '',
phone: json['phone'] ?? '',
address: json['address'] ?? '',
profilePic: json['profile_pic'] ?? '',
category: json['category'] ?? 'General',
experience: (json['experience'] ?? 0).toString(),
rating: double.parse((json['rating'] ?? 4.5).toString()),
hourlyRate: (json['hourly_rate'] ?? 500).toString(),
description: json['description'] ?? 'Professional Artist',
);
}
}
