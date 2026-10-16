import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth/auth_service.dart';
import '../services/api/api_exception.dart';

/// Authentication state
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Authentication provider for state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService.instance {
    _authService.sessionInvalidated.addListener(_sessionExpired);
  }

  void _sessionExpired() {
    _user = null;
    _state = AuthState.unauthenticated;
    _errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    notifyListeners();
  }

  bool get isAdmin => isAuthenticated && _user!.isAdmin;
  bool get isStaff => isAuthenticated && _user!.isStaff;
  bool can(String permission) =>
      isAuthenticated && _user!.hasPermission(permission);

  @override
  void dispose() {
    _authService.sessionInvalidated.removeListener(_sessionExpired);
    super.dispose();
  }

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;

  Future<Map<String, bool>> oauthProviders() => _authService.oauthProviders();
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _user = null;
      _state = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Không đổi được mật khẩu. Vui lòng thử lại.';
    }
    notifyListeners();
    return false;
  }

  Future<void> startOAuth(String provider) => _authService.startOAuth(provider);
  Future<bool> completeOAuth() async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authService.completeOAuth();
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Không hoàn tất được đăng nhập. Vui lòng thử lại.';
    }
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
    return false;
  }

  /// Initialize - check if user is already authenticated
  Future<void> initialize() async {
    try {
      _state = AuthState.loading;
      notifyListeners();
      _user = await _authService.restoreSession();
      _state = _user == null
          ? AuthState.unauthenticated
          : AuthState.authenticated;
    } catch (e) {
      _user = null;
      _state = AuthState.unauthenticated;
      _errorMessage = 'Failed to restore session';
    }
    notifyListeners();
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Registration failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.login(email: email, password: password);

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on UnauthorizedException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Login failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Login as guest
  Future<bool> loginAsGuest() async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.loginAsGuest();

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Guest login failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Convert guest to permanent account
  Future<bool> convertGuest({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.convertGuest(
        email: email,
        password: password,
        displayName: displayName,
      );

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Account conversion failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _state = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      if (_state == AuthState.authenticated) {
        _user = await _authService.getCurrentUser();
        notifyListeners();
      }
    } on UnauthorizedException {
      _sessionExpired();
    } catch (e) {
      debugPrint('Failed to refresh user: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
