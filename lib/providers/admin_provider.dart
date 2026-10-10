import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/admin_stats_model.dart';
import '../models/session_model.dart';
import '../models/dictionary_entry_model.dart';
import '../services/admin/admin_service.dart';

/// Provider for admin operations
class AdminProvider extends ChangeNotifier {
  final AdminService _adminService;

  List<UserModel> _users = [];
  UserModel? _selectedUser;
  AdminStatsModel? _stats;
  List<DictionaryEntryModel> _pendingContent = [];
  List<SessionModel> _sessions = [];
  Map<String, dynamic> _usersPagination = {};
  Map<String, dynamic> _contentPagination = {};
  Map<String, dynamic> _sessionsPagination = {};
  bool _isLoading = false;
  String? _errorMessage;

  AdminProvider({AdminService? adminService})
      : _adminService = adminService ?? AdminService.instance;

  // Getters
  List<UserModel> get users => _users;
  UserModel? get selectedUser => _selectedUser;
  AdminStatsModel? get stats => _stats;
  List<DictionaryEntryModel> get pendingContent => _pendingContent;
  List<SessionModel> get sessions => _sessions;
  Map<String, dynamic> get usersPagination => _usersPagination;
  Map<String, dynamic> get contentPagination => _contentPagination;
  Map<String, dynamic> get sessionsPagination => _sessionsPagination;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load users with filters
  Future<void> loadUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    String? status,
    String? accountType,
    String? sortBy,
    String? order,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _adminService.getUsers(
        page: page,
        limit: limit,
        search: search,
        role: role,
        status: status,
        accountType: accountType,
        sortBy: sortBy,
        order: order,
      );
      _users = result['users'] as List<UserModel>;
      _usersPagination = result['pagination'] as Map<String, dynamic>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user by ID
  Future<void> loadUserById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedUser = await _adminService.getUserById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user
  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _adminService.updateUser(id, data);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_selectedUser?.id == id) {
        _selectedUser = updatedUser;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete user
  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      if (_selectedUser?.id == id) {
        _selectedUser = null;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Suspend user
  Future<bool> suspendUser(String id, String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _adminService.suspendUser(id, reason);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_selectedUser?.id == id) {
        _selectedUser = updatedUser;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Activate user
  Future<bool> activateUser(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _adminService.activateUser(id);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_selectedUser?.id == id) {
        _selectedUser = updatedUser;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load system statistics
  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _adminService.getStats();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load pending content
  Future<void> loadPendingContent({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _adminService.getPendingContent(page: page, limit: limit);
      _pendingContent = result['entries'] as List<DictionaryEntryModel>;
      _contentPagination = result['pagination'] as Map<String, dynamic>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load active sessions
  Future<void> loadSessions({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _adminService.getSessions(page: page, limit: limit);
      _sessions = result['sessions'] as List<SessionModel>;
      _sessionsPagination = result['pagination'] as Map<String, dynamic>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Terminate session
  Future<bool> terminateSession(String sessionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.terminateSession(sessionId);
      _sessions.removeWhere((s) => s.sessionId == sessionId);
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

  /// Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }
}
