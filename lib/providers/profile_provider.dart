import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user/user_service.dart';

/// Provider for user profile
class ProfileProvider extends ChangeNotifier {
  final UserService _userService;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider({UserService? userService})
      : _userService = userService ?? UserService.instance;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user profile
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.getProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
