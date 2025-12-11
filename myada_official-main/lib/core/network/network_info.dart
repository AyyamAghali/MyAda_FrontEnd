import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// Option 2: Define globalMessengerKey locally here if not defined elsewhere.
final GlobalKey<ScaffoldMessengerState> globalMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// For checking internet connectivity
abstract class NetworkInfoI {
  Future<bool> isConnected();

  Future<ConnectivityResult> get connectivityResult;

  Stream<ConnectivityResult> get onConnectivityChanged;
}

class NetworkInfo implements NetworkInfoI {
  final Connectivity connectivity;

  static final NetworkInfo _networkInfo = NetworkInfo._internal(Connectivity());

  factory NetworkInfo() {
    return _networkInfo;
  }

  NetworkInfo._internal(this.connectivity);

  /// Returns true if the internet is connected; otherwise false.
  @override
  Future<bool> isConnected() async {
    final result = await connectivityResult;
    return result != ConnectivityResult.none;
  }

  /// Checks the current connectivity status.
  @override
  Future<ConnectivityResult> get connectivityResult async {
    return connectivity.checkConnectivity();
  }

  /// Provides a stream of connectivity changes.
  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      connectivity.onConnectivityChanged;
}

/// Abstract Failure class for error handling.
abstract class Failure {}

// General failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class ServerException implements Exception {}

class CacheException implements Exception {}

class NetworkException implements Exception {}

/// Can be used for throwing a [NoInternetException].
class NoInternetException implements Exception {
  late String _message;

  NoInternetException([String message = 'NoInternetException Occurred']) {
    if (globalMessengerKey.currentState != null) {
      globalMessengerKey.currentState!
          .showSnackBar(SnackBar(content: Text(message)));
    }
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
