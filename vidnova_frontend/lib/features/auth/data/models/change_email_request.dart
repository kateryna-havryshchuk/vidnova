class ChangeEmailRequest {
  final String newEmail;
  final String currentPassword;

  ChangeEmailRequest({
    required this.newEmail,
    required this.currentPassword,
  });

  Map<String, dynamic> toJson() => {
        'newEmail': newEmail,
        'currentPassword': currentPassword,
      };
}
