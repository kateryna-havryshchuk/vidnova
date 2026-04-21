import '../../data/models/me_response.dart';

class AuthState {
  final bool isLoading;
  final MeResponse? me;
  final String? error;

  bool get isAuthenticated => me != null;

  AuthState({
    this.isLoading = false,
    this.me,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    MeResponse? me,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      me: me ?? this.me,
      error: clearError ? null : (error ?? this.error),
    );
  }

  factory AuthState.initial() => AuthState();
}