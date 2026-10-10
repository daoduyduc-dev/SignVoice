import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';
import '../storage/secure_token_storage.dart';

/// HTTP client with authentication and error handling
class ApiClient {
  static ApiClient? _instance;
  final http.Client _client;
  final SecureTokenStorage _tokenStorage;

  ApiClient._()
      : _client = http.Client(),
        _tokenStorage = SecureTokenStorage.instance;

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// Build full URL
  String _buildUrl(String endpoint) {
    return '${ApiConfig.baseUrl}$endpoint';
  }

  /// Get headers with optional authentication
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Try to parse response body
    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (e) {
      body = {'message': response.body};
    }

    // Handle success
    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    // Extract error message
    String message = 'Request failed';
    String? code;
    Map<String, dynamic>? details;

    if (body is Map<String, dynamic>) {
      if (body['error'] != null && body['error'] is Map) {
        final error = body['error'] as Map<String, dynamic>;
        message = error['message'] ?? message;
        code = error['code'];
        details = error['details'];
      } else {
        message = body['message'] ?? message;
        code = body['code'];
      }
    }

    // Throw appropriate exception
    switch (statusCode) {
      case 401:
        if (code == 'TOKEN_EXPIRED' || code == 'AUTH_TOKEN_EXPIRED') {
          throw TokenExpiredException(message: message);
        }
        throw UnauthorizedException(message: message);
      case 403:
        throw ForbiddenException(message: message);
      case 404:
        throw NotFoundException(message: message);
      case 400:
        throw ValidationException(message: message, details: details);
      case 500:
      case 502:
      case 503:
        throw ServerException(message: message);
      default:
        throw ApiException(
          message: message,
          code: code,
          statusCode: statusCode,
          details: details,
        );
    }
  }

  /// Handle network errors
  Never _handleError(dynamic error) {
    if (error is SocketException) {
      throw NetworkException(message: 'No internet connection');
    } else if (error is HttpException) {
      throw NetworkException(message: 'Network error: ${error.message}');
    } else if (error is FormatException) {
      throw ApiException(message: 'Invalid response format');
    } else if (error is ApiException) {
      throw error;
    } else {
      throw ApiException(message: 'Unexpected error: $error');
    }
  }

  /// Refresh access token
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        throw UnauthorizedException(message: 'No refresh token available');
      }

      final response = await _client.post(
        Uri.parse(_buildUrl('${ApiConfig.authEndpoint}/refresh')),
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      final data = _handleResponse(response);
      if (data != null &&
          data['success'] == true &&
          data['data'] != null &&
          data['data']['accessToken'] != null) {
        await _tokenStorage.saveAccessToken(data['data']['accessToken']);
      } else {
        throw UnauthorizedException(message: 'Failed to refresh token');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint))
          .replace(queryParameters: queryParameters);

      final response = await _client
          .get(
            uri,
            headers: await _getHeaders(includeAuth: requiresAuth),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TokenExpiredException {
      // Try to refresh token and retry
      await refreshToken();
      return get(endpoint,
          queryParameters: queryParameters, requiresAuth: requiresAuth);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_buildUrl(endpoint)),
            headers: await _getHeaders(includeAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TokenExpiredException {
      await refreshToken();
      return post(endpoint, body: body, requiresAuth: requiresAuth);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(_buildUrl(endpoint)),
            headers: await _getHeaders(includeAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TokenExpiredException {
      await refreshToken();
      return put(endpoint, body: body, requiresAuth: requiresAuth);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PATCH request
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .patch(
            Uri.parse(_buildUrl(endpoint)),
            headers: await _getHeaders(includeAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TokenExpiredException {
      await refreshToken();
      return patch(endpoint, body: body, requiresAuth: requiresAuth);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(_buildUrl(endpoint)),
            headers: await _getHeaders(includeAuth: requiresAuth),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TokenExpiredException {
      await refreshToken();
      return delete(endpoint, requiresAuth: requiresAuth);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Close the client
  void dispose() {
    _client.close();
  }
}
