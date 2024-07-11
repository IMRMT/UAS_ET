class User {
  final int user_id;
  final String user_email;
  final String user_name;
  final String user_password;


  User(
      {required this.user_id,
      required this.user_email,
      required this.user_name,
      required this.user_password,});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      user_id: json['user_id'] as int,
      user_email: json['user_email'] as String,
      user_name: json['user_name'] as String,
      user_password: json['user_password'] as String
    );
  }
}