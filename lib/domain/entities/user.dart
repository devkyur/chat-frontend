class User {
  final int id;
  final int userId;
  final String nickname;
  final String? birthDate;
  final String? gender;
  final String? bio;
  final String? location;
  final List<String> imageUrls;
  final List<String> interests;
  final int? minAgePreference;
  final int? maxAgePreference;
  final int? maxDistance;

  const User({
    required this.id,
    required this.userId,
    required this.nickname,
    this.birthDate,
    this.gender,
    this.bio,
    this.location,
    this.imageUrls = const [],
    this.interests = const [],
    this.minAgePreference,
    this.maxAgePreference,
    this.maxDistance,
  });
}
