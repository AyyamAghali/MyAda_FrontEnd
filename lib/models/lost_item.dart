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

  LostItem({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.dateFound,
    required this.status,
    required this.imageUrl,
  });

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
}

