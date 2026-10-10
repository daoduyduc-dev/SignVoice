import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';

/// Manages token storage and retrieval
class TokenStorage {
  static TokenStorage? _instance;
  SharedPreferences? _prefs;

  TokenStorage._();

  static TokenStorage get instance {
    _instance ??= TokenStorage._();
    return _instance!;
  }

  /// Initialize storage
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save access token
  Future<bool> saveAccessToken(String token) async {
    await init();
    return _prefs!.setString(ApiConfig.accessTokenKey, token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    await init();
    return _prefs!.getString(ApiConfig.accessTokenKey);
  }

  /// Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    await init();
    return _prefs!.setString(ApiConfig.refreshTokenKey, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    await init();
    return _prefs!.getString(ApiConfig.refreshTokenKey);
  }

  /// Save both tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// Save user info
  Future<void> saveUserInfo({
    required String userId,
    required String role,
  }) async {
    await init();
    await Future.wait([
      _prefs!.setString(ApiConfig.userIdKey, userId),
      _prefs!.setString(ApiConfig.userRoleKey, role),
    ]);
  }

  /// Get user role
  Future<String?> getUserRole() async {
    await init();
    return _prefs!.getString(ApiConfig.userRoleKey);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    await init();
    return _prefs!.getString(ApiConfig.userIdKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all tokens and user info
  Future<void> clearAll() async {
    await init();
    await Future.wait([
      _prefs!.remove(ApiConfig.accessTokenKey),
      _prefs!.remove(ApiConfig.refreshTokenKey),
      _prefs!.remove(ApiConfig.userIdKey),
      _prefs!.remove(ApiConfig.userRoleKey),
    ]);
  }

  /// Clear only tokens (keep user info for re-login)
  Future<void> clearTokens() async {
    await init();
    await Future.wait([
      _prefs!.remove(ApiConfig.accessTokenKey),
      _prefs!.remove(ApiConfig.refreshTokenKey),
    ]);
  }
}
