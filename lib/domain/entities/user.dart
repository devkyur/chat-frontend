class User {
  final int id;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final int? age;
  final String? gender;
  final String? bio;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    this.age,
    this.gender,
    this.bio,
  });
}
