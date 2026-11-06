class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
  });

  final String id;
  final String fullName;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
      );
}
