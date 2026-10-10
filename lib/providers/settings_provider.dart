import 'package:flutter/foundation.dart';
import '../models/user_settings_model.dart';
import '../services/user/user_service.dart';

/// Provider for user settings
class SettingsProvider extends ChangeNotifier {
  final UserService _userService;

  UserSettingsModel? _settings;
  bool _isLoading = false;
  String? _errorMessage;

  SettingsProvider({UserService? userService})
      : _userService = userService ?? UserService.instance;

  // Getters
  UserSettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user settings
  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _userService.getSettings();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user settings
  Future<bool> updateSettings({
    String? theme,
    String? language,
    bool? notifications,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _userService.updateSettings(
        theme: theme,
        language: language,
        notifications: notifications,
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
