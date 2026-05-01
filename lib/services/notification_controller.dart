import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../models/app_notification.dart';
import 'auth_service.dart';
import 'notification_api_service.dart';

class NotificationController extends ChangeNotifier {
  NotificationController._();

  static final NotificationController instance = NotificationController._();

  final NotificationApiService _api = const NotificationApiService();

  HubConnection? _connection;
  Future<void>? _startInFlight;
  bool _loading = false;
  String? _error;
  List<AppNotification> _items = const [];

  List<AppNotification> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  int get count => _items.length;
  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  Future<void> initialize() async {
    await AuthService.instance.loadSession();
    if (!AuthService.instance.hasSession) return;
    await refresh();
    unawaited(connect());
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await _api.fetchMyNotifications();
      _items = _sortedNewestFirst(loaded);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> connect() async {
    await AuthService.instance.loadSession();
    if (!AuthService.instance.hasSession) return;
    if (isConnected) return;
    if (_startInFlight != null) return _startInFlight;

    _startInFlight = _doConnect().whenComplete(() => _startInFlight = null);
    return _startInFlight;
  }

  Future<void> disconnect() async {
    final current = _connection;
    _connection = null;
    if (current != null) {
      try {
        await current.stop();
      } catch (_) {}
    }
    _items = const [];
    _error = null;
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    final before = _items;
    _items = _items.where((n) => n.id != id).toList(growable: false);
    notifyListeners();
    try {
      await _api.deleteNotification(id);
    } catch (e) {
      _items = before;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _doConnect() async {
    final existing = _connection;
    if (existing != null &&
        existing.state != HubConnectionState.Disconnected) {
      await existing.stop();
    }

    final connection = HubConnectionBuilder()
        .withUrl(
          kNotificationHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                AuthService.instance.accessToken ?? '',
            requestTimeout: 20000,
          ),
        )
        .withAutomaticReconnect()
        .build();

    connection.serverTimeoutInMilliseconds = 60000;
    connection.keepAliveIntervalInMilliseconds = 15000;
    connection.on('notificationCreated', _handleNotificationCreated);

    _connection = connection;
    await connection.start();
  }

  void _handleNotificationCreated(List<Object?>? args) {
    final map = _firstMap(args);
    if (map == null) return;
    final notification = AppNotification.fromJson(map);
    if (notification.id.isEmpty) return;

    final withoutDuplicate = _items
        .where((item) => item.id != notification.id)
        .toList(growable: true);
    _items = [notification, ...withoutDuplicate];
    _error = null;
    notifyListeners();
  }

  List<AppNotification> _sortedNewestFirst(List<AppNotification> source) {
    final out = source.toList(growable: false);
    out.sort((a, b) {
      final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return out;
  }

  Map<String, dynamic>? _firstMap(List<Object?>? args) {
    if (args == null || args.isEmpty) return null;
    final first = args.first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return first.cast<String, dynamic>();
    return null;
  }
}
