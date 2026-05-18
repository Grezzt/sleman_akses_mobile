class UserModel {
  UserModel({required this.id, required this.fullName, required this.email});

  final int id;
  final String fullName;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['user_id'] ?? json['id'] ?? 0) as int,
      fullName: (json['full_name'] ?? json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
    );
  }
}
