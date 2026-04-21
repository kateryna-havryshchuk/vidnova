class ApiConfig {
  // Для Windows desktop (Kestrel): http://localhost:5080
  // Для Android emulator (host loopback): http://10.0.2.2:5080

  // Опційний оверрайд:
  // flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5080
  static const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const String baseUrlWindows = 'http://localhost:5080';
  static const String baseUrlAndroidEmulator = 'http://10.0.2.2:5080';

  static String baseUrl({required bool isAndroidEmulator}) {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    return isAndroidEmulator ? baseUrlAndroidEmulator : baseUrlWindows;
  }
}