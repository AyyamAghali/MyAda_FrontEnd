import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/lost_item.dart';
import 'auth_service.dart';

// ── Toggle ────────────────────────────────────────────────────────────────────

/// Controls which data source the Lost & Found module uses.
///
///   [false] → live backend (API gateway at `http://13.60.31.141:5000/lostfound`).
///   [true]  → local mock data only; no network calls are made.
///
/// Flip this single constant to switch between modes.
const bool kLostFoundUseMockData = false;

// ── Exception ─────────────────────────────────────────────────────────────────

class LostFoundException implements Exception {
  final int? statusCode;
  final String message;

  const LostFoundException({this.statusCode, required this.message});

  @override
  String toString() => 'LostFoundException($statusCode): $message';
}

// ── Service ───────────────────────────────────────────────────────────────────

class LostFoundService {
  static const String _base = 'http://13.60.31.141:5000/lostfound';

  // ── Mock data (used when kLostFoundUseMockData == true) ───────────────────

  static final List<LostItem> mockItems = [
    LostItem(
      id: '1',
      title: 'Black Leather Wallet',
      category: ItemCategory.accessories,
      location: 'Library - 2nd Floor, near the study pods',
      description:
          'Black leather wallet found near study area. Contains some cards but no ID.',
      dateFound: '2025-11-10',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '2',
      title: 'iPhone 14 Pro',
      category: ItemCategory.electronics,
      location: 'Main Building - Room A120',
      description:
          'Blue iPhone 14 Pro with cracked screen protector. Has a sticker on the back.',
      dateFound: '2025-11-11',
      status: ItemStatus.pendingVerification,
      imageUrl:
          'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '3',
      title: 'Student ID Card',
      category: ItemCategory.documents,
      location: 'Cafeteria - Lobby near the main entrance',
      description:
          'ADA University student ID card. Found on table near main entrance.',
      dateFound: '2025-11-09',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1614624532983-4ce03382d63d?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '4',
      title: 'Navy Blue Jacket',
      category: ItemCategory.clothing,
      location: 'Sports Complex - Men\'s locker room, bench area',
      description: 'Navy blue jacket with ADA logo on left chest. Size M.',
      dateFound: '2025-11-08',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '5',
      title: 'AirPods Pro Case',
      category: ItemCategory.electronics,
      location: 'Campus - Main yard, on the bench near the fountain',
      description:
          'White AirPods Pro case found on a bench. No name written on it.',
      dateFound: '2025-11-12',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '6',
      title: 'House Keys',
      category: ItemCategory.other,
      location: 'Campus - Parking Area B, ground level near exit gate',
      description:
          'Set of 3 keys on a red keychain with a small teddy bear charm.',
      dateFound: '2025-11-13',
      status: ItemStatus.pendingVerification,
      imageUrl:
          'https://images.unsplash.com/photo-1582139329536-e7284fece509?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '7',
      title: 'Prescription Glasses',
      category: ItemCategory.accessories,
      location: 'Main Building - Room A301',
      description:
          'Black-framed prescription glasses in a brown leather case. Found after lecture.',
      dateFound: '2025-11-14',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1574258495973-f7977603b6d2?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '8',
      title: 'Silver MacBook Charger',
      category: ItemCategory.electronics,
      location: 'Campus - Outdoor seating area between Block A and Block B',
      description:
          'Apple 67W USB-C charger with a small scratch on the adapter. Was in a transparent ziplock bag.',
      dateFound: '2025-11-15',
      status: ItemStatus.active,
      isLostItem: true,
      imageUrl:
          'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '9',
      title: 'Red Notebook',
      category: ItemCategory.other,
      location: 'Library - 3rd Floor, reading hall near the windows',
      description:
          'Red Moleskine notebook with handwritten notes in Azerbaijani. Has a pen clipped to the cover.',
      dateFound: '2025-11-16',
      status: ItemStatus.active,
      isLostItem: true,
      imageUrl:
          'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '10',
      title: 'USB Flash Drive',
      category: ItemCategory.electronics,
      location: 'Building C - Room C203',
      description:
          'SanDisk 64GB flash drive with a blue cap. Contains important project files.',
      dateFound: '2025-11-17',
      status: ItemStatus.pendingVerification,
      isLostItem: true,
      imageUrl:
          'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=400&h=300&fit=crop',
    ),
  ];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches available categories from the backend.
  ///
  /// Returns a list of `{id, name}` maps.
  /// Falls back to hardcoded defaults when [kLostFoundUseMockData] is `true`
  /// or on network failure.
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    if (kLostFoundUseMockData) return fallbackCategories;

    try {
      final uri = Uri.parse('$_base/api/v1/categories');
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          list = (decoded['data'] ?? decoded['categories'] ?? decoded['items'] ?? [])
              as List<dynamic>;
        } else {
          list = [];
        }
        if (list.isNotEmpty) {
          return list.map((e) {
            final m = e as Map<String, dynamic>;
            return <String, dynamic>{
              'id': m['id'] ?? m['categoryId'] ?? 0,
              'name': (m['name'] ?? m['categoryName'] ?? '').toString(),
            };
          }).where((c) => (c['name'] as String).isNotEmpty).toList();
        }
      }
    } catch (_) {
      // fall through to defaults
    }
    return fallbackCategories;
  }

  static final List<Map<String, dynamic>> fallbackCategories = [
    {'id': 1, 'name': 'Electronics'},
    {'id': 2, 'name': 'Documents'},
    {'id': 3, 'name': 'Clothing'},
    {'id': 4, 'name': 'Accessories'},
    {'id': 5, 'name': 'Other'},
  ];

  /// Returns all items.
  ///
  /// When [kLostFoundUseMockData] is `true`, returns the static mock list.
  /// When `false`, fetches from `GET /lostfound/api/lost-and-found/items`.
  Future<List<LostItem>> fetchItems() async {
    if (kLostFoundUseMockData) return List.unmodifiable(mockItems);

    try {
      final uri = Uri.parse('$_base/api/lost-and-found/items');
      final response = await http.get(uri, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          list = (decoded['items'] ??
              decoded['data'] ??
              decoded['results'] ??
              []) as List<dynamic>;
        } else {
          list = [];
        }
        return list
            .map((e) => LostItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final msg = _extractMsg(response.body) ?? 'Could not load items.';
      throw LostFoundException(statusCode: response.statusCode, message: msg);
    } on LostFoundException {
      rethrow;
    } on SocketException {
      throw const LostFoundException(
          message: 'No internet connection. Check your network and try again.');
    } on TimeoutException {
      throw const LostFoundException(
          message: 'Request timed out. Please try again.');
    } catch (e) {
      throw LostFoundException(
          message: 'Unexpected error (${e.runtimeType}). Please try again.');
    }
  }

  /// Reports a lost item.
  ///
  /// No-op (returns immediately) when [kLostFoundUseMockData] is `true`.
  /// Otherwise posts to `POST /lostfound/api/lost-and-found/reports/lost`.
  Future<void> reportLost({
    required String title,
    required int categoryId,
    required String description,
    required String locationType,
    String? building,
    bool? isRoom,
    String? roomArea,
    String? campusLocation,
    String? location,
    String? collectionPlace,
    List<XFile> imageFiles = const [],
  }) async {
    if (kLostFoundUseMockData) return;
    await _submitReport(
      path: '/api/lost-and-found/reports/lost',
      title: title,
      categoryId: categoryId,
      description: description,
      locationType: locationType,
      building: building,
      isRoom: isRoom,
      roomArea: roomArea,
      campusLocation: campusLocation,
      location: location,
      collectionPlace: collectionPlace,
      imageFiles: imageFiles,
    );
  }

  /// Reports a found item.
  ///
  /// No-op (returns immediately) when [kLostFoundUseMockData] is `true`.
  /// Otherwise posts to `POST /lostfound/api/lost-and-found/reports/found`.
  Future<void> reportFound({
    required String title,
    required int categoryId,
    required String description,
    required String locationType,
    String? building,
    bool? isRoom,
    String? roomArea,
    String? campusLocation,
    String? location,
    required String collectionPlace,
    List<XFile> imageFiles = const [],
  }) async {
    if (kLostFoundUseMockData) return;
    await _submitReport(
      path: '/api/lost-and-found/reports/found',
      title: title,
      categoryId: categoryId,
      description: description,
      locationType: locationType,
      building: building,
      isRoom: isRoom,
      roomArea: roomArea,
      campusLocation: campusLocation,
      location: location,
      collectionPlace: collectionPlace,
      imageFiles: imageFiles,
    );
  }

  /// Claims an item as the authenticated user's own property.
  ///
  /// No-op when [kLostFoundUseMockData] is `true`.
  /// Otherwise posts to `POST /lostfound/api/lost-and-found/items/{id}/claims`.
  Future<void> claimItem(String itemId) async {
    if (kLostFoundUseMockData) return;

    final uri = Uri.parse('$_base/api/lost-and-found/items/$itemId/claims');
    try {
      final response = await AuthService.instance
          .sendAuthorized(
            (token) => http
                .post(
                  uri,
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: jsonEncode(<String, dynamic>{
                    'claimType': 'owner',
                  }),
                )
                .timeout(const Duration(seconds: 20)),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200 || response.statusCode == 201) return;

      final msg = _extractMsg(response.body) ?? 'Claim submission failed.';
      throw LostFoundException(statusCode: response.statusCode, message: msg);
    } on LostFoundException {
      rethrow;
    } on SocketException {
      throw const LostFoundException(
          message: 'No internet connection. Check your network and try again.');
    } on TimeoutException {
      throw const LostFoundException(
          message: 'Request timed out. Please try again.');
    } catch (e) {
      if (e is LostFoundException) rethrow;
      throw LostFoundException(
          message: 'Unexpected error (${e.runtimeType}). Please try again.');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _submitReport({
    required String path,
    required String title,
    required int categoryId,
    required String description,
    required String locationType,
    String? building,
    bool? isRoom,
    String? roomArea,
    String? campusLocation,
    String? location,
    String? collectionPlace,
    List<XFile> imageFiles = const [],
  }) async {
    final uri = Uri.parse('$_base$path');
    try {
      final http.Response response;

      if (imageFiles.isNotEmpty) {
        final req = http.MultipartRequest('POST', uri)
          ..fields['itemName'] = title
          ..fields['categoryId'] = categoryId.toString()
          ..fields['description'] = description
          ..fields['locationType'] = locationType;

        if (locationType == 'building') {
          if (building != null && building.isNotEmpty) {
            req.fields['building'] = building;
          }
          if (isRoom != null) req.fields['isRoom'] = isRoom.toString();
          if (roomArea != null && roomArea.isNotEmpty) {
            req.fields['roomArea'] = roomArea;
          }
        } else if (locationType == 'campus') {
          if (campusLocation != null && campusLocation.isNotEmpty) {
            req.fields['campusLocation'] = campusLocation;
          }
        } else {
          if (location != null && location.isNotEmpty) {
            req.fields['location'] = location;
          }
        }

        final cp = collectionPlace?.trim();
        if (cp != null && cp.isNotEmpty) {
          req.fields['collectionPlace'] = cp;
        }

        for (final file in imageFiles) {
          req.files.add(
              await http.MultipartFile.fromPath('imageFile', file.path));
        }
        final streamed = await req.send().timeout(const Duration(seconds: 40));
        response = await http.Response.fromStream(streamed);
      } else {
        final body = <String, dynamic>{
          'itemName': title,
          'categoryId': categoryId,
          'description': description,
          'locationType': locationType,
        };

        if (locationType == 'building') {
          if (building != null && building.isNotEmpty) {
            body['building'] = building;
          }
          if (isRoom != null) body['isRoom'] = isRoom;
          if (roomArea != null && roomArea.isNotEmpty) {
            body['roomArea'] = roomArea;
          }
        } else if (locationType == 'campus') {
          if (campusLocation != null && campusLocation.isNotEmpty) {
            body['campusLocation'] = campusLocation;
          }
        } else {
          if (location != null && location.isNotEmpty) {
            body['location'] = location;
          }
        }

        final cp = collectionPlace?.trim();
        if (cp != null && cp.isNotEmpty) body['collectionPlace'] = cp;

        response = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 20));
      }

      if (response.statusCode == 200 || response.statusCode == 201) return;
      final msg = _extractMsg(response.body) ?? 'Submission failed.';
      throw LostFoundException(statusCode: response.statusCode, message: msg);
    } on LostFoundException {
      rethrow;
    } on SocketException {
      throw const LostFoundException(
          message: 'No internet connection. Check your network and try again.');
    } on TimeoutException {
      throw const LostFoundException(
          message: 'Request timed out. Please try again.');
    } catch (e) {
      if (e is LostFoundException) rethrow;
      throw LostFoundException(
          message: 'Unexpected error (${e.runtimeType}). Please try again.');
    }
  }

  String? _extractMsg(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      final direct = map['message'] ?? map['error'] ?? map['detail'];
      if (direct is String && direct.isNotEmpty) return direct;
      final details = map['details'];
      if (details is Map<String, dynamic>) {
        for (final v in details.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String && v.isNotEmpty) return v;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
