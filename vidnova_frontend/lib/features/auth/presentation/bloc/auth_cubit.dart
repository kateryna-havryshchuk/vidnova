import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/auth_repository.dart';
import '../../data/models/change_email_request.dart';
import '../../data/models/change_password_request.dart';
import '../../data/models/google_login_request.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/set_password_request.dart';
import 'auth_state.dart';

const _googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthState.initial());

  void clearError() {
    if (state.error == null) return;
    emit(state.copyWith(clearError: true));
  }

  Future<void> bootstrap() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final me = await _repo.me();
      emit(state.copyWith(isLoading: false, me: me));
    } catch (e) {
      emit(state.copyWith(isLoading: false, me: null));
    }
  }

  Future<void> refreshMe() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final me = await _repo.me();
      emit(state.copyWith(isLoading: false, me: me));
    } catch (e) {
      // Don't drop auth state on refresh failures.
      emit(state.copyWith(isLoading: false, error: _extractError(e)));
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repo.register(RegisterRequest(
        email: email,
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
      ));

      final me = await _repo.me();
      emit(state.copyWith(isLoading: false, me: me));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: _extractError(e)));
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repo.login(LoginRequest(username: username, password: password));
      final me = await _repo.me();
      emit(state.copyWith(isLoading: false, me: me));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: _extractError(e)));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final googleSignIn = GoogleSignIn(
        scopes: const ['email'],
        // Для отримання idToken на Android зазвичай потрібен Web OAuth Client ID
        // (serverClientId). Передай його через:
        // flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=...apps.googleusercontent.com
        serverClientId: _googleServerClientId.isNotEmpty ? _googleServerClientId : null,
      );

      final account = await googleSignIn.signIn();

      if (account == null) {
        // User cancelled.
        emit(state.copyWith(isLoading: false));
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        final hint = _googleServerClientId.isEmpty
            ? ' (додай --dart-define=GOOGLE_SERVER_CLIENT_ID=твій_WEB_client_id)'
            : '';
        emit(state.copyWith(isLoading: false, error: 'Google sign-in: не вдалося отримати idToken$hint'));
        return;
      }

      await _repo.googleLogin(GoogleLoginRequest(idToken: idToken));
      final me = await _repo.me();
      emit(state.copyWith(isLoading: false, me: me));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: _extractError(e)));
    }
  }

  Future<void> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repo.changeEmail(ChangeEmailRequest(
        newEmail: newEmail,
        currentPassword: currentPassword,
      ));
      final me = await _repo.me();
      emit(state.copyWith(isLoading: false, me: me));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: _extractError(e)));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repo.changePassword(ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ));
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: _extractError(e)));
    }
  }

  Future<void> setPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repo.setPassword(SetPasswordRequest(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ));

      final me = await _repo.me();
      emit(state.copyWith(isLoading: false, me: me));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: _extractError(e)));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthState.initial());
  }

  String _extractError(Object e) {
    if (e is PlatformException) {
      final message = (e.message ?? '').trim();
      if (message.isNotEmpty) return message;
      final code = e.code.trim();
      if (code.isNotEmpty) return 'Google sign-in error: $code';
      return 'Google sign-in error';
    }
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError || e.response == null) {
        return 'Network error: не вдалось підключитись до API';
      }

      final status = e.response?.statusCode;
      final data = e.response?.data;

      // ASP.NET ProblemDetails / ValidationProblemDetails
      if (data is Map) {
        final detail = data['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return _withStatus(detail.trim(), status);
        }

        final title = data['title'];
        if (title is String && title.trim().isNotEmpty) {
          // For validation responses, sometimes only "title" and "errors" exist.
          final validation = _tryExtractValidationErrors(data);
          if (validation != null) return _withStatus(validation, status);
          return _withStatus(title.trim(), status);
        }

        final validation = _tryExtractValidationErrors(data);
        if (validation != null) return _withStatus(validation, status);
      }

      if (data is String && data.trim().isNotEmpty) {
        final trimmed = data.trim();
        if (trimmed.toLowerCase().contains('invalid hostname')) {
          return _withStatus('Bad Request - Invalid Hostname (запусти API через Kestrel, не IIS Express)', status);
        }
        return _withStatus(trimmed, status);
      }

      // Common fallbacks when the server returns no JSON body.
      final fallback = switch (status) {
        400 => 'Некоректний запит',
        401 => 'Не авторизовано. Увійдіть знову.',
        403 => 'Немає прав доступу',
        404 => 'Нічого не знайдено (перевір baseUrl і шлях API)',
        409 => 'Такий користувач вже існує',
        500 => 'Помилка сервера',
        _ => null,
      };

      return _withStatus(fallback ?? (e.message ?? 'Request failed'), status);
    }
    return 'Unexpected error';
  }

  String _withStatus(String message, int? status) {
    final trimmed = message.trim();
    if (status == null) return trimmed;

    final lower = trimmed.toLowerCase();

    // Конфлікти на бекенді інколи приходять як 400/409 з англ. текстом — мапимо незалежно від коду.
    if (lower.contains('username already registered') || lower.contains('username is already registered')) {
      return 'Такий username вже зайнятий';
    }
    if (lower.contains('email already registered') || lower.contains('email is already registered')) {
      return 'Такий email вже зареєстрований';
    }

    if (status == 401) {
      if (lower.contains('invalid credentials')) {
        return 'Невірний email/username або пароль';
      }
      if (lower.contains('unauthorized')) {
        return 'Не авторизовано. Увійдіть знову.';
      }
    }

    if (status == 409) {
      if (lower.contains('already registered') || lower.contains('already exists')) {
        return 'Користувач з такими даними вже існує';
      }
    }

    return trimmed;
  }

  String? _tryExtractValidationErrors(Map data) {
    final errors = data['errors'];
    if (errors is Map) {
      for (final entry in errors.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          if (first is String && first.trim().isNotEmpty) return first.trim();
        }
      }
    }
    return null;
  }
}