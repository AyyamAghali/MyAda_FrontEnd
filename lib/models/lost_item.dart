enum ItemStatus {
  pendingVerification,
  active,
  resolved,
}

enum ItemCategory {
  electronics,
  documents,
  clothing,
  accessories,
  other,
}

class LostItem {
  final String id;
  final String title;
  final ItemCategory category;
  final String location;
  final String description;
  final String dateFound;
  final ItemStatus status;
  final String imageUrl;
  final bool isLostItem;

  LostItem({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.dateFound,
    required this.status,
    required this.imageUrl,
    this.isLostItem = false,
  });

  String get typeString => isLostItem ? 'Lost item' : 'Found item';

  String get statusString {
    switch (status) {
      case ItemStatus.pendingVerification:
        return 'Pending Verification';
      case ItemStatus.active:
        return 'Active';
      case ItemStatus.resolved:
        return 'Resolved';
    }
  }

  String get categoryString {
    switch (category) {
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.documents:
        return 'Documents';
      case ItemCategory.clothing:
        return 'Clothing';
      case ItemCategory.accessories:
        return 'Accessories';
      case ItemCategory.other:
        return 'Other';
    }
  }

  String get categoryIcon {
    switch (category) {
      case ItemCategory.electronics:
        return '📱';
      case ItemCategory.documents:
        return '📄';
      case ItemCategory.clothing:
        return '👕';
      case ItemCategory.accessories:
        return '🎒';
      case ItemCategory.other:
        return '📦';
    }
  }

  /// Constructs a [LostItem] from a gateway API JSON object.
  ///
  /// Handles common field-name variations returned by the backend
  /// (camelCase, snake_case, alternate spellings).
  factory LostItem.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['itemId'] ?? '').toString();
    final title =
        (json['title'] ?? json['name'] ?? json['itemName'] ?? '') as String;
    final location =
        (json['location'] ?? json['locationText'] ?? json['address'] ?? '')
            as String;
    final description = (json['description'] ?? '') as String;

    final categoryRaw =
        (json['category'] ?? json['categoryName'] ?? '').toString();
    final statusRaw =
        (json['status'] ?? json['itemStatus'] ?? 'active').toString();
    final typeRaw =
        (json['type'] ?? json['itemType'] ?? json['reportType'] ?? '')
            .toString()
            .toLowerCase();
    final isLost =
        json['isLost'] as bool? ?? json['isLostItem'] as bool? ?? typeRaw == 'lost';

    final dateRaw =
        (json['createdAt'] ?? json['reportedAt'] ?? json['dateFound'] ?? '')
            .toString();
    final date = dateRaw.length >= 10
        ? dateRaw.substring(0, 10)
        : DateTime.now().toIso8601String().substring(0, 10);

    final imageRaw =
        (json['imageUrl'] ?? json['image'] ?? json['photoUrl'] ?? json['photo'] ?? '')
            .toString();
    const _fallbackImage =
        'https://images.unsplash.com/photo-1614624532983-4ce03382d63d?w=400&h=300&fit=crop';

    return LostItem(
      id: id,
      title: title.isNotEmpty ? title : 'Unnamed Item',
      category: _categoryFromString(categoryRaw),
      location: location.isNotEmpty ? location : 'Unknown location',
      description: description,
      dateFound: date,
      status: _statusFromString(statusRaw),
      imageUrl: imageRaw.isNotEmpty ? imageRaw : _fallbackImage,
      isLostItem: isLost,
    );
  }

  static ItemCategory _categoryFromString(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('electron') || s.contains('phone') || s.contains('laptop') ||
        s.contains('device')) {
      return ItemCategory.electronics;
    }
    if (s.contains('document') || s.contains('card') || s.contains('id') ||
        s.contains('passport') || s.contains('book')) {
      return ItemCategory.documents;
    }
    if (s.contains('cloth') || s.contains('jacket') || s.contains('shirt') ||
        s.contains('pants') || s.contains('wear') || s.contains('coat')) {
      return ItemCategory.clothing;
    }
    if (s.contains('accessor') || s.contains('watch') || s.contains('glass') ||
        s.contains('wallet') || s.contains('bag') || s.contains('purse') ||
        s.contains('belt') || s.contains('jewel')) {
      return ItemCategory.accessories;
    }
    return ItemCategory.other;
  }

  static ItemStatus _statusFromString(String raw) {
    final s = raw.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    if (s.contains('pending') || s.contains('verification') ||
        s.contains('review') || s.contains('unverified')) {
      return ItemStatus.pendingVerification;
    }
    if (s.contains('resolved') || s.contains('claimed') ||
        s.contains('returned') || s.contains('closed') ||
        s.contains('complete')) {
      return ItemStatus.resolved;
    }
    return ItemStatus.active;
  }
}
