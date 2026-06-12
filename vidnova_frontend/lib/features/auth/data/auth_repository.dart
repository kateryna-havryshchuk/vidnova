import '../../../core/storage/token_storage.dart';
import 'auth_api.dart';
import 'models/auth_response.dart';
import 'models/change_email_request.dart';
import 'models/change_password_request.dart';
import 'models/google_login_request.dart';
import 'models/login_request.dart';
import 'models/me_response.dart';
import 'models/register_request.dart';
import 'models/set_password_request.dart';

class AuthRepository {
  final AuthApi api;
  final TokenStorage tokenStorage;

  AuthRepository({
    required this.api,
    required this.tokenStorage,
  });

  Future<AuthResponse> register(RegisterRequest req) async {
    final result = await api.register(req);
    await tokenStorage.saveAccessToken(result.accessToken);
    return result;
  }

  Future<AuthResponse> login(LoginRequest req) async {
    final result = await api.login(req);
    await tokenStorage.saveAccessToken(result.accessToken);
    return result;
  }

  Future<AuthResponse> googleLogin(GoogleLoginRequest req) async {
    final result = await api.googleLogin(req);
    await tokenStorage.saveAccessToken(result.accessToken);
    return result;
  }

  Future<MeResponse> me() => api.me();

  Future<void> changeEmail(ChangeEmailRequest req) => api.changeEmail(req);

  Future<void> changePassword(ChangePasswordRequest req) => api.changePassword(req);

  Future<void> setPassword(SetPasswordRequest req) => api.setPassword(req);

  Future<void> logout() => tokenStorage.clear();
}