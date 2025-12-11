import '../../domain/entities/user.dart';

class UserModel {
  final int id;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final int? age;
  final String? gender;
  final String? bio;

  const UserModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    this.age,
    this.gender,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'age': age,
      'gender': gender,
      'bio': bio,
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      age: age,
      gender: gender,
      bio: bio,
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
  final String nickname;

  const SignupRequest({
    required this.email,
    required this.password,
    required this.nickname,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) {
    return SignupRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      nickname: json['nickname'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'nickname': nickname,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}
