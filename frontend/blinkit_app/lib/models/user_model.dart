class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.phone = '',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['created_at'],
    );
  }
}
