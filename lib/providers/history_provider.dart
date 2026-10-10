import 'package:flutter/foundation.dart';
import '../models/history_entry_model.dart';
import '../services/history/history_service.dart';

/// Provider for user history
class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService;

  List<HistoryEntryModel> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  HistoryProvider({HistoryService? historyService})
      : _historyService = historyService ?? HistoryService.instance;

  // Getters
  List<HistoryEntryModel> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user history
  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _history = await _historyService.getHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all history
  Future<bool> clearHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _historyService.clearHistory();
      _history.clear();
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
