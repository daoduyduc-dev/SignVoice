import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_config.dart';
import 'token_store.dart';

/// Native tokens use secure storage; browsers keep access tokens in memory
/// and send the refresh token in a server-issued HttpOnly cookie.
class SecureTokenStorage implements TokenStore {
  SecureTokenStorage._();
  static final instance = SecureTokenStorage._();
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  SharedPreferences? _prefs;
  String? _webAccessToken;

  Future<void> init() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    // Remove tokens written by the old, unencrypted implementation.
    await _prefs!.remove(ApiConfig.accessTokenKey);
    await _prefs!.remove(ApiConfig.refreshTokenKey);
  }

  Future<bool> saveAccessToken(String token) async {
    if (kIsWeb) {
      _webAccessToken = token;
    } else {
      await _secureStorage.write(key: ApiConfig.accessTokenKey, value: token);
    }
    return true;
  }

  @override
  Future<String?> getAccessToken() async {
    await init();
    return kIsWeb
        ? _webAccessToken
        : _secureStorage.read(key: ApiConfig.accessTokenKey);
  }

  Future<bool> saveRefreshToken(String token) async {
    if (!kIsWeb) {
      await _secureStorage.write(key: ApiConfig.refreshTokenKey, value: token);
    }
    return true;
  }

  @override
  Future<String?> getRefreshToken() async {
    await init();
    return kIsWeb ? null : _secureStorage.read(key: ApiConfig.refreshTokenKey);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await init();
    await saveRefreshToken(refreshToken);
    await saveAccessToken(accessToken);
  }

  @override
  Future<void> saveUserInfo({
    required String userId,
    required String role,
  }) async {
    await init();
    await _prefs!.setString(ApiConfig.userIdKey, userId);
    await _prefs!.setString(ApiConfig.userRoleKey, role);
  }

  @override
  Future<String?> getUserRole() async {
    await init();
    return _prefs!.getString(ApiConfig.userRoleKey);
  }

  Future<String?> getUserId() async {
    await init();
    return _prefs!.getString(ApiConfig.userIdKey);
  }

  @override
  Future<bool> isAuthenticated() async =>
      (await getAccessToken())?.isNotEmpty == true;

  Future<void> clearTokens() async {
    _webAccessToken = null;
    if (!kIsWeb) {
      await _secureStorage.delete(key: ApiConfig.accessTokenKey);
      await _secureStorage.delete(key: ApiConfig.refreshTokenKey);
    }
  }

  @override
  Future<void> clearAll() async {
    await clearTokens();
    await init();
    await _prefs!.remove(ApiConfig.userIdKey);
    await _prefs!.remove(ApiConfig.userRoleKey);
  }
}
