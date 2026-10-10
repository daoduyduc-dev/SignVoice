import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';

/// Secure token storage using platform-appropriate mechanisms
/// 
/// Android: Uses flutter_secure_storage (Android Keystore)
/// Web: Uses in-memory storage for access token, SharedPreferences for non-sensitive data
///      (Backend should use HttpOnly cookies for refresh tokens on Web)
class SecureTokenStorage {
  static SecureTokenStorage? _instance;
  
  // Secure storage for Android
  final FlutterSecureStorage? _secureStorage;
  
  // SharedPreferences for Web and non-sensitive data
  SharedPreferences? _prefs;
  
  // In-memory storage for Web access tokens
  String? _webAccessToken;
  
  SecureTokenStorage._()
      : _secureStorage = kIsWeb ? null : const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  static SecureTokenStorage get instance {
    _instance ??= SecureTokenStorage._();
    return _instance!;
  }

  /// Initialize storage
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save access token
  Future<bool> saveAccessToken(String token) async {
    await init();
    
    if (kIsWeb) {
      // Web: Store in memory only (short-lived)
      _webAccessToken = token;
      return true;
    } else {
      // Android: Use secure storage
      try {
        await _secureStorage!.write(
          key: ApiConfig.accessTokenKey,
          value: token,
        );
        return true;
      } catch (e) {
        print('Error saving access token: $e');
        return false;
      }
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    await init();
    
    if (kIsWeb) {
      // Web: Return from memory
      return _webAccessToken;
    } else {
      // Android: Read from secure storage
      try {
        return await _secureStorage!.read(key: ApiConfig.accessTokenKey);
      } catch (e) {
        print('Error reading access token: $e');
        return null;
      }
    }
  }

  /// Save refresh token
  /// 
  /// IMPORTANT FOR WEB:
  /// The backend should issue refresh tokens as HttpOnly cookies for Web.
  /// This method stores the token only on Android (secure storage).
  /// On Web, this is a no-op since the browser handles HttpOnly cookies automatically.
  Future<bool> saveRefreshToken(String token) async {
    await init();
    
    if (kIsWeb) {
      // Web: Backend should use HttpOnly cookie
      // We don't store refresh tokens client-side on Web for security
      print('Web: Refresh token should be managed via HttpOnly cookie');
      return true;
    } else {
      // Android: Use secure storage
      try {
        await _secureStorage!.write(
          key: ApiConfig.refreshTokenKey,
          value: token,
        );
        return true;
      } catch (e) {
        print('Error saving refresh token: $e');
        return false;
      }
    }
  }

  /// Get refresh token
  /// 
  /// Returns token on Android (from secure storage).
  /// Returns null on Web (backend handles via HttpOnly cookie).
  Future<String?> getRefreshToken() async {
    await init();
    
    if (kIsWeb) {
      // Web: Cookie-based, not accessible to JavaScript
      return null;
    } else {
      // Android: Read from secure storage
      try {
        return await _secureStorage!.read(key: ApiConfig.refreshTokenKey);
      } catch (e) {
        print('Error reading refresh token: $e');
        return null;
      }
    }
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

  /// Save user info (non-sensitive)
  /// Uses SharedPreferences on all platforms
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

  /// Get user role (non-sensitive)
  Future<String?> getUserRole() async {
    await init();
    return _prefs!.getString(ApiConfig.userRoleKey);
  }

  /// Get user ID (non-sensitive)
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
    
    if (kIsWeb) {
      // Web: Clear memory
      _webAccessToken = null;
      // Note: Backend should clear HttpOnly cookie on logout endpoint
    } else {
      // Android: Clear secure storage
      try {
        await Future.wait([
          _secureStorage!.delete(key: ApiConfig.accessTokenKey),
          _secureStorage!.delete(key: ApiConfig.refreshTokenKey),
        ]);
      } catch (e) {
        print('Error clearing secure storage: $e');
      }
    }
    
    // Clear user info from SharedPreferences (all platforms)
    await Future.wait([
      _prefs!.remove(ApiConfig.userIdKey),
      _prefs!.remove(ApiConfig.userRoleKey),
    ]);
  }

  /// Clear only tokens (keep user info for re-login)
  Future<void> clearTokens() async {
    await init();
    
    if (kIsWeb) {
      _webAccessToken = null;
    } else {
      try {
        await Future.wait([
          _secureStorage!.delete(key: ApiConfig.accessTokenKey),
          _secureStorage!.delete(key: ApiConfig.refreshTokenKey),
        ]);
      } catch (e) {
        print('Error clearing tokens: $e');
      }
    }
  }

  /// Handle corrupted storage (Android specific)
  Future<void> handleCorruptedStorage() async {
    if (!kIsWeb) {
      try {
        await _secureStorage!.deleteAll();
      } catch (e) {
        print('Error handling corrupted storage: $e');
      }
    }
  }
}
