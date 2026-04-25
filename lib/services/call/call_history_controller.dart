import 'dart:async';

import 'package:flutter/foundation.dart';

import 'call_api.dart';

class CallHistoryController extends ChangeNotifier {
  CallHistoryController._();

  static final CallHistoryController instance = CallHistoryController._();

  final CallApiClient _api = const CallApiClient();

  CallHistoryStatus _filter = CallHistoryStatus.all;
  List<CallHistoryItem> _items = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  CallHistoryStatus get filter => _filter;
  List<CallHistoryItem> get items => _items;
  String get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _searchQuery.trim().isNotEmpty || _filter != CallHistoryStatus.all;

  /// Items after client-side search (server list is already status-filtered).
  List<CallHistoryItem> get visibleItems {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((e) {
      bool contains(String? s) => s != null && s.toLowerCase().contains(q);
      return e.callId.toLowerCase().contains(q) ||
          e.caller.displayName.toLowerCase().contains(q) ||
          e.dispatcher.displayName.toLowerCase().contains(q) ||
          e.caller.userId.toLowerCase().contains(q) ||
          e.dispatcher.userId.toLowerCase().contains(q) ||
          contains(e.resolveReason) ||
          contains(e.endReason);
    }).toList(growable: false);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> clearFilters() async {
    _searchQuery = '';
    await load(status: CallHistoryStatus.all);
  }

  Future<void> load({
    CallHistoryStatus? status,
    int limit = 200,
    bool showLoading = true,
  }) async {
    final nextFilter = status ?? _filter;
    _filter = nextFilter;
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await _api.fetchCallHistory(
        status: nextFilter,
        limit: limit.clamp(1, 200),
      );
      _items = result;
      _errorMessage = null;
    } catch (err) {
      _errorMessage = err.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CallHistoryItem> fetchItem(String callId) {
    return _api.fetchCallHistoryItem(callId);
  }

  Future<void> setFilter(CallHistoryStatus status) {
    return load(status: status);
  }

  void refreshAfterRealtimeEvent() {
    unawaited(load(showLoading: false));
  }
}
