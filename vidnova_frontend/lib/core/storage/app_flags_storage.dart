import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppFlagsStorage {
  static const _helpPromptShownKey = 'help_prompt_shown';
  static const _helpPromptPendingKey = 'help_prompt_pending';

  final FlutterSecureStorage _storage;

  AppFlagsStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> readHelpPromptShown() async {
    final v = await _storage.read(key: _helpPromptShownKey);
    return v == '1' || v?.toLowerCase() == 'true';
  }

  Future<void> writeHelpPromptShown(bool value) {
    return _storage.write(key: _helpPromptShownKey, value: value ? '1' : '0');
  }

  Future<bool> readHelpPromptPending() async {
    final v = await _storage.read(key: _helpPromptPendingKey);
    return v == '1' || v?.toLowerCase() == 'true';
  }

  Future<void> writeHelpPromptPending(bool value) {
    return _storage.write(key: _helpPromptPendingKey, value: value ? '1' : '0');
  }
}
