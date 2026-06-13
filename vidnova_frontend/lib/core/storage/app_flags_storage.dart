import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppFlagsStorage {
  static const _helpPromptShownPrefix = 'help_prompt_shown';
  static const _helpPromptPendingPrefix = 'help_prompt_pending';

  final FlutterSecureStorage _storage;

  AppFlagsStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> readHelpPromptShown(String userKey) async {
    final v = await _storage.read(key: _keyFor(_helpPromptShownPrefix, userKey));
    return v == '1' || v?.toLowerCase() == 'true';
  }

  Future<void> writeHelpPromptShown(String userKey, bool value) {
    return _storage.write(key: _keyFor(_helpPromptShownPrefix, userKey), value: value ? '1' : '0');
  }

  Future<bool> readHelpPromptPending(String userKey) async {
    final v = await _storage.read(key: _keyFor(_helpPromptPendingPrefix, userKey));
    return v == '1' || v?.toLowerCase() == 'true';
  }

  Future<void> writeHelpPromptPending(String userKey, bool value) {
    return _storage.write(key: _keyFor(_helpPromptPendingPrefix, userKey), value: value ? '1' : '0');
  }

  String _keyFor(String prefix, String userKey) {
    final normalized = userKey.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]+'), '_');
    return '${prefix}_$normalized';
  }
}
