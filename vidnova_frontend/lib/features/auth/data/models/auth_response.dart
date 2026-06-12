class AuthResponse {
  final String userId;
  final String email;
  final String userName;
  final String accessToken;
  final String expiresAtUtc;

  AuthResponse({
    required this.userId,
    required this.email,
    required this.userName,
    required this.accessToken,
    required this.expiresAtUtc,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        userId: json['userId'] as String,
        email: json['email'] as String,
        userName: json['userName'] as String,
        accessToken: json['accessToken'] as String,
        expiresAtUtc: json['expiresAtUtc'] as String,
      );
}