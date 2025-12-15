import '../../domain/entities/user.dart';

class UserModel {
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

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      birthDate: json['birthDate'] as String?,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      minAgePreference: json['minAgePreference'] as int?,
      maxAgePreference: json['maxAgePreference'] as int?,
      maxDistance: json['maxDistance'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nickname': nickname,
      'birthDate': birthDate,
      'gender': gender,
      'bio': bio,
      'location': location,
      'imageUrls': imageUrls,
      'interests': interests,
      'minAgePreference': minAgePreference,
      'maxAgePreference': maxAgePreference,
      'maxDistance': maxDistance,
    };
  }

  User toEntity() {
    return User(
      id: id,
      userId: userId,
      nickname: nickname,
      birthDate: birthDate,
      gender: gender,
      bio: bio,
      location: location,
      imageUrls: imageUrls,
      interests: interests,
      minAgePreference: minAgePreference,
      maxAgePreference: maxAgePreference,
      maxDistance: maxDistance,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class SignupRequest {
  final String email;
  final String password;
  final String name;
  final String nickname;
  final String birthDate;
  final String gender;
  final String? phoneNumber;
  final String? bio;
  final String? location;
  final int? minAgePreference;
  final int? maxAgePreference;
  final int? maxDistance;

  const SignupRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.nickname,
    required this.birthDate,
    required this.gender,
    this.phoneNumber,
    this.bio,
    this.location,
    this.minAgePreference,
    this.maxAgePreference,
    this.maxDistance,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) {
    return SignupRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      birthDate: json['birthDate'] as String,
      gender: json['gender'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      minAgePreference: json['minAgePreference'] as int?,
      maxAgePreference: json['maxAgePreference'] as int?,
      maxDistance: json['maxDistance'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'name': name,
      'nickname': nickname,
      'birthDate': birthDate,
      'gender': gender,
    };

    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    if (bio != null) map['bio'] = bio;
    if (location != null) map['location'] = location;
    if (minAgePreference != null) map['minAgePreference'] = minAgePreference;
    if (maxAgePreference != null) map['maxAgePreference'] = maxAgePreference;
    if (maxDistance != null) map['maxDistance'] = maxDistance;

    return map;
  }
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
