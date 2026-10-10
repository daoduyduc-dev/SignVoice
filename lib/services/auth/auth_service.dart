import '../api/api_client.dart';
import '../api/api_config.dart';
import '../storage/secure_token_storage.dart';
import '../../models/user_model.dart';

/// Authentication service
class AuthService {
  static AuthService? _instance;
  final ApiClient _apiClient;
  final SecureTokenStorage _tokenStorage;

  AuthService._()
      : _apiClient = ApiClient.instance,
        _tokenStorage = SecureTokenStorage.instance;

  static AuthService get instance {
    _instance ??= AuthService._();
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
      body: {
        'email': email,
        'password': password,
        'displayName': displayName,
      },
      requiresAuth: false,
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      
      // Save tokens
      await _tokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      // Save user info
      final user = UserModel.fromJson(data['user']);
      await _tokenStorage.saveUserInfo(
        userId: user.id,
        role: user.roleName,
      );

      return user;
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
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      
      // Save tokens
      await _tokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      // Save user info
      final user = UserModel.fromJson(data['user']);
      await _tokenStorage.saveUserInfo(
        userId: user.id,
        role: user.roleName,
      );

      return user;
    }

    throw Exception('Login failed');
  }

  /// Login as guest
  Future<UserModel> loginAsGuest() async {
    final response = await _apiClient.post(
      '${ApiConfig.authEndpoint}/guest',
      requiresAuth: false,
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      
      // Save tokens
      await _tokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      // Save user info
      final user = UserModel.fromJson(data['user']);
      await _tokenStorage.saveUserInfo(
        userId: user.id,
        role: user.roleName,
      );

      return user;
    }

    throw Exception('Guest login failed');
  }

  /// Convert guest to permanent account
  Future<UserModel> convertGuest({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '${ApiConfig.authEndpoint}/convert-guest',
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: true,
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      
      // Update tokens if provided
      if (data['accessToken'] != null && data['refreshToken'] != null) {
        await _tokenStorage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
      }

      // Update user info
      final user = UserModel.fromJson(data['user']);
      await _tokenStorage.saveUserInfo(
        userId: user.id,
        role: user.roleName,
      );

      return user;
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
      await _apiClient.post(
        '${ApiConfig.authEndpoint}/logout',
        requiresAuth: true,
      );
    } finally {
      // Clear tokens even if request fails
      await _tokenStorage.clearAll();
    }
  }

  /// Logout from all devices
  Future<void> logoutAll() async {
    try {
      await _apiClient.post(
        '${ApiConfig.authEndpoint}/logout-all',
        requiresAuth: true,
      );
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
    final userRole = await getUserRole();
    return userRole == role;
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    return hasRole('ADMIN');
  }

  /// Check if user is staff (staff or admin)
  Future<bool> isStaff() async {
    final userRole = await getUserRole();
    return userRole == 'STAFF' || userRole == 'ADMIN';
  }
}
