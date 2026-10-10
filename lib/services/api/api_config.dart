/// API Configuration
class ApiConfig {
  // Base URL - change based on environment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';

  // Endpoints
  static const String authEndpoint = '/auth';
  static const String dictionaryEndpoint = '/dictionary';
  static const String categoriesEndpoint = '/categories';
  static const String favoritesEndpoint = '/favorites';
  static const String historyEndpoint = '/history';
  static const String usersEndpoint = '/users';
  static const String staffEndpoint = '/staff';
  static const String adminEndpoint = '/admin';
}
