import 'package:credential_manager/credential_manager.dart';
import 'package:flutter/foundation.dart';

class CredentialService {
  static final CredentialManager _manager = CredentialManager();

  static bool get isSupported => _manager.isSupportedPlatform;

  static Future<void> init() async {
    if (_manager.isSupportedPlatform) {
      await _manager.init(preferImmediatelyAvailableCredentials: true);
    }
  }

  static Future<void> saveCredential({
    required String phoneNumber,
    required String password,
  }) async {
    if (!_manager.isSupportedPlatform) return;
    try {
      await _manager.savePasswordCredentials(
        PasswordCredential(username: phoneNumber, password: password),
      );
    } catch (e) {
      debugPrint('[CredentialService] Save failed: $e');
    }
  }

  static Future<PasswordCredential?> getCredential() async {
    if (!_manager.isSupportedPlatform) return null;
    try {
      final credentials = await _manager.getCredentials(
        fetchOptions: FetchOptionsAndroid(passwordCredential: true),
      );
      return credentials.passwordCredential;
    } catch (e) {
      debugPrint('[CredentialService] Get failed: $e');
      return null;
    }
  }
}
