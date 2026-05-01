import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

const List<String> kLocationApiBaseCandidates = [
  'http://13.60.31.141:500/location',
  'http://13.60.31.141:5000/location',
];

class LocationApiException implements Exception {
  final int? statusCode;
  final String message;

  const LocationApiException({this.statusCode, required this.message});

  @override
  String toString() => 'LocationApiException($statusCode): $message';
}

class LocationBuilding {
  final int id;
  final String name;

  const LocationBuilding({required this.id, required this.name});

  factory LocationBuilding.fromJson(Map<String, dynamic> json) {
    return LocationBuilding(
      id: _readInt(json['id'] ?? json['buildingId']),
      name: (json['name'] ?? json['buildingName'] ?? '').toString(),
    );
  }
}

class LocationRoom {
  final int id;
  final String name;
  final String number;
  final int buildingId;
  final String buildingName;

  const LocationRoom({
    required this.id,
    required this.name,
    required this.number,
    required this.buildingId,
    required this.buildingName,
  });

  String get displayName {
    if (number.isEmpty) return name;
    if (name.isEmpty || name == number) return number;
    return '$number - $name';
  }

  factory LocationRoom.fromJson(Map<String, dynamic> json) {
    return LocationRoom(
      id: _readInt(json['id'] ?? json['roomId']),
      name: (json['name'] ?? json['roomName'] ?? '').toString(),
      number: (json['number'] ?? json['roomNumber'] ?? '').toString(),
      buildingId: _readInt(json['buildingId']),
      buildingName: (json['buildingName'] ?? '').toString(),
    );
  }
}

class LocationApiService {
  static String? _sessionBase;

  Future<List<LocationBuilding>> fetchBuildings() async {
    final data = await _getList('/api/v1/buildings');
    return data
        .map((e) => LocationBuilding.fromJson(e))
        .where((b) => b.id > 0 && b.name.isNotEmpty)
        .toList();
  }

  Future<List<LocationRoom>> fetchRoomsByBuilding(int buildingId) async {
    final data = await _getList('/api/v1/rooms/by-building/$buildingId');
    return data
        .map((e) => LocationRoom.fromJson(e))
        .where((r) => r.id > 0 && r.displayName.isNotEmpty)
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    LocationApiException? last;
    for (final base in _orderedBases()) {
      try {
        final uri = Uri.parse('$base$path');
        final response = await http.get(uri, headers: {
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          _sessionBase = base;
          final decoded = jsonDecode(response.body);
          final List<dynamic> list;
          if (decoded is List) {
            list = decoded;
          } else if (decoded is Map) {
            list = (decoded['data'] ??
                decoded['items'] ??
                decoded['results'] ??
                decoded['buildings'] ??
                decoded['rooms'] ??
                []) as List<dynamic>;
          } else {
            list = [];
          }
          return list.cast<Map<String, dynamic>>();
        }

        last = LocationApiException(
          statusCode: response.statusCode,
          message: _extractMsg(response.body) ?? 'Could not load locations.',
        );
      } on TimeoutException {
        last = const LocationApiException(message: 'Request timed out.');
      } on SocketException {
        last = const LocationApiException(message: 'No internet connection.');
      } catch (e) {
        last = LocationApiException(
          message: 'Unexpected location error (${e.runtimeType}).',
        );
      }
    }

    throw last ??
        const LocationApiException(message: 'Could not load locations.');
  }

  List<String> _orderedBases() {
    final out = <String>[];
    if (_sessionBase != null) out.add(_sessionBase!);
    for (final base in kLocationApiBaseCandidates) {
      if (!out.contains(base)) out.add(base);
    }
    return out;
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _extractMsg(String body) {
  try {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final direct = map['message'] ?? map['error'] ?? map['detail'];
    return direct is String && direct.isNotEmpty ? direct : null;
  } catch (_) {
    return null;
  }
}
