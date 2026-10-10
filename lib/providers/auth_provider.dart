import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth/auth_service.dart';
import '../services/api/api_exception.dart';

/// Authentication state
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication provider for state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;

  /// Initialize - check if user is already authenticated
  Future<void> initialize() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _state = AuthState.loading;
        notifyListeners();

        _user = await _authService.getCurrentUser();
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
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
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.login(
        email: email,
        password: password,
      );

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
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.convertGuest(
        email: email,
        password: password,
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
