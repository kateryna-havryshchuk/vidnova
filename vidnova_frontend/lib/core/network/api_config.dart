class ApiConfig {
  // For Windows desktop (Kestrel): http://localhost:5080
  // For Android emulator (host loopback): http://10.0.2.2:5080
  // For Android real device (PC IP on Wi-Fi): http://192.168.1.50:5080

  // Опційний оверрайд:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.50:5080
  static const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const String baseUrlWindows = 'http://localhost:5080';
  static const String baseUrlAndroidEmulator = 'http://10.0.2.2:5080';

  static String baseUrl({required bool isAndroidEmulator}) {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    return isAndroidEmulator ? baseUrlAndroidEmulator : baseUrlWindows;
  }
}