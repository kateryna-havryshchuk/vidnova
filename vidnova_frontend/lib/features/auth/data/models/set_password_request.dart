class SetPasswordRequest {
  final String newPassword;
  final String confirmPassword;

  SetPasswordRequest({
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };
}
