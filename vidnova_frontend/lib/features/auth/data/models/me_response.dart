class MeResponse {
  final String userId;
  final String email;
  final String userName;
  final String firstName;
  final String lastName;
  final bool hasPassword;
  final bool isGoogleAccount;

  MeResponse({
    required this.userId,
    required this.email,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.hasPassword,
    required this.isGoogleAccount,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) => MeResponse(
        userId: json['userId'] as String,
        email: json['email'] as String,
        userName: json['userName'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        hasPassword: json['hasPassword'] as bool? ?? false,
        isGoogleAccount: json['isGoogleAccount'] as bool? ?? false,
      );
}