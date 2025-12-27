class LoginModel {
  bool? status;
  String? message;
  User? user;

  LoginModel({this.status, this.message, this.user});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    user = json['data'] != null ? new User.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.user != null) {
      data['data'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? role;
  String? isApproved;
  String? isActive;
  String? createdAt;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.role,
    this.isApproved,
    this.isActive,
    this.createdAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    role = json['role'];
    isApproved = json['is_approved'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['role'] = this.role;
    data['is_approved'] = this.isApproved;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    return data;
  }
}
