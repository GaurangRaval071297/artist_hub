class RegisterModel {
  bool? status;
  String? message;
  User? user;

  RegisterModel({this.status, this.message, this.user});

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      status: json['status'],
      message: json['message'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  int? userId;
  int? artistId;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? role;
  String? profilePic;

  User({
    this.userId,
    this.artistId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.role,
    this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      artistId: json['artist_id'] != null ? int.tryParse(json['artist_id'].toString()) : null,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'],
      profilePic: json['profile_pic'],
    );
  }
}