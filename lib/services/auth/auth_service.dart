import '../api/api_client.dart';
import '../api/api_config.dart';
import '../storage/secure_token_storage.dart';
import '../../models/user_model.dart';
import '../storage/token_store.dart';
import '../api/api_exception.dart';

import 'package:flutter/foundation.dart';

/// Authentication service
class AuthService {
  static AuthService? _instance;
  final ApiClient _apiClient;
  final TokenStore _tokenStorage;

  AuthService({ApiClient? apiClient, TokenStore? tokenStorage})
    : _apiClient = apiClient ?? ApiClient.instance,
      _tokenStorage = tokenStorage ?? SecureTokenStorage.instance;

  ValueListenable<int> get sessionInvalidated => _apiClient.sessionInvalidated;

  Future<UserModel?> restoreSession() async {
    if (!await _tokenStorage.isAuthenticated()) {
      // Metadata permits attempting cookie refresh; authorization comes from /me.
      // Its absence also records an intentional logout, including while offline.
      if (_apiClient.useRefreshCookie &&
          await _tokenStorage.getUserRole() == null) {
        return null;
      }
      if (!_apiClient.useRefreshCookie &&
          await _tokenStorage.getRefreshToken() == null) {
        return null;
      }
      await _apiClient.refreshToken();
    }
    return getCurrentUser();
  }

  Future<UserModel> _saveAuthResponse(dynamic response) async {
    final data = response['data'];
    final user = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
    final tokens = data['tokens'];
    await _tokenStorage.saveTokens(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
    );
    await _tokenStorage.saveUserInfo(userId: user.id, role: user.roleName);
    _apiClient.sessionStarted();
    return user;
  }

  static AuthService get instance {
    _instance ??= AuthService();
    return _instance!;
  }

  /// Register new user
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _apiClient.post(
      '${ApiConfig.authEndpoint}/register',
      body: {'email': email, 'password': password, 'displayName': displayName},
      requiresAuth: false,
    );

    if (response['success'] == true && response['data'] != null) {
      return _saveAuthResponse(response);
    }

    throw Exception('Registration failed');
  }

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '${ApiConfig.authEndpoint}/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );

    if (response['success'] == true && response['data'] != null) {
      return _saveAuthResponse(response);
    }

    throw Exception('Login failed');
  }

  /// Login as guest
  Future<void> requestPasswordReset(String email) async {
    await _apiClient.post(
      '${ApiConfig.authEndpoint}/forgot-password',
      body: {'email': email.trim()},
      requiresAuth: false,
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '${ApiConfig.authEndpoint}/reset-password',
      body: {'token': token, 'newPassword': newPassword},
      requiresAuth: false,
    );
    await _tokenStorage.clearAll();
    _apiClient.sessionInvalidated.value++;
  }

  /// Login as guest
  Future<UserModel> loginAsGuest() async {
    final response = await _apiClient.post(
      '${ApiConfig.authEndpoint}/guest',
      requiresAuth: false,
    );

    if (response['success'] == true && response['data'] != null) {
      return _saveAuthResponse(response);
    }

    throw Exception('Guest login failed');
  }

  /// Convert guest to permanent account
  Future<UserModel> convertGuest({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _apiClient.post(
      '${ApiConfig.authEndpoint}/convert-guest',
      body: {'email': email, 'password': password, 'displayName': displayName},
      requiresAuth: true,
    );

    if (response['success'] == true && response['data'] != null) {
      return _saveAuthResponse(response);
    }

    throw Exception('Guest conversion failed');
  }

  /// Get current user
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(
      '${ApiConfig.authEndpoint}/me',
      requiresAuth: true,
    );

    if (response['success'] == true && response['data'] != null) {
      return UserModel.fromJson(response['data']);
    }

    throw Exception('Failed to get current user');
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } finally {
      // Clear tokens even if request fails
      await _tokenStorage.clearAll();
    }
  }

  /// Logout from all devices
  Future<void> logoutAll() async {
    try {
      await _apiClient.logout(allDevices: true);
    } finally {
      await _tokenStorage.clearAll();
    }
  }

  /// Refresh access token
  Future<void> refreshToken() async {
    await _apiClient.refreshToken();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _tokenStorage.isAuthenticated();
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return _tokenStorage.getUserRole();
  }

  /// Check if user has specific role
  Future<bool> hasRole(String role) async {
    try {
      return (await getCurrentUser()).roleName == role;
    } on ApiException {
      return false;
    }
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    return hasRole('ADMIN');
  }

  /// Check if user is staff (staff or admin)
  Future<bool> isStaff() async {
    return (await getCurrentUser()).isStaff;
  }
}
