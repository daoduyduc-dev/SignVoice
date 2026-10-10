import 'secure_token_storage.dart';

/// Compatibility entry point for the previous token store.
/// All token operations now use the platform secure implementation.
@Deprecated('Use SecureTokenStorage instead')
class TokenStorage {
  TokenStorage._();
  static SecureTokenStorage get instance => SecureTokenStorage.instance;
}
