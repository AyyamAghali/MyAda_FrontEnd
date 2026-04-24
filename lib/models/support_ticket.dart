enum TicketStatus {
  pending,
  assigned,
  inProgress,
  completed,
  cancelled,
}

enum TicketPriority {
  low,
  medium,
  high,
}

enum TicketCategory {
  wifiNetwork,
  emailOffice365,
  passwordReset,
  projectorDisplay,
  printerScanner,
  softwareInstallation,
  computerRepair,
  other,
}

class SupportTicket {
  final int? requestId;
  final String id;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketStatus status;
  final TicketPriority priority;
  final String location;
  final String createdAt;
  final String? assignedTo;
  final String? completedAt;
  final String? cancelledReason;
  final int? rating;
  final String type; // 'IT' or 'FM'

  SupportTicket({
    this.requestId,
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.location,
    required this.createdAt,
    this.assignedTo,
    this.completedAt,
    this.cancelledReason,
    this.rating,
    required this.type,
  });

  factory SupportTicket.fromApiJson(Map<String, dynamic> json) {
    int? asInt(Object? raw) => int.tryParse((raw ?? '').toString());
    DateTime? asDate(Object? raw) => DateTime.tryParse((raw ?? '').toString());

    TicketStatus parseStatus(Object? raw) {
      final s = (raw ?? '')
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll('_', '')
          .replaceAll(' ', '');
      if (s.contains('cancel')) return TicketStatus.cancelled;
      if (s.contains('complete') ||
          s.contains('resolved') ||
          s.contains('done')) {
        return TicketStatus.completed;
      }
      if (s.contains('progress') || s == 'inwork')
        return TicketStatus.inProgress;
      if (s.contains('assign') || s.contains('accepted'))
        return TicketStatus.assigned;
      return TicketStatus.pending;
    }

    TicketPriority parsePriority(Object? raw) {
      final s = (raw ?? '').toString().trim().toLowerCase();
      if (s == 'urgent' || s == 'high' || s == 'critical')
        return TicketPriority.high;
      if (s == 'medium' || s == 'normal' || s == 'standard')
        return TicketPriority.medium;
      return TicketPriority.low;
    }

    TicketCategory parseCategory(Object? raw) {
      final source = raw is Map<String, dynamic>
          ? (raw['name'] ?? raw['categoryName'] ?? raw['tag'] ?? '')
          : raw;
      final s = (source ?? '').toString().trim().toLowerCase();
      if (s.contains('wifi') || s.contains('network'))
        return TicketCategory.wifiNetwork;
      if (s.contains('email') || s.contains('office'))
        return TicketCategory.emailOffice365;
      if (s.contains('password')) return TicketCategory.passwordReset;
      if (s.contains('projector') || s.contains('display'))
        return TicketCategory.projectorDisplay;
      if (s.contains('printer') || s.contains('scanner'))
        return TicketCategory.printerScanner;
      if (s.contains('software') || s.contains('install'))
        return TicketCategory.softwareInstallation;
      if (s.contains('repair') || s.contains('hardware'))
        return TicketCategory.computerRepair;
      return TicketCategory.other;
    }

    String composeLocation() {
      final direct = (json['location'] ?? '').toString().trim();
      if (direct.isNotEmpty) return direct;
      final building =
          (json['buildingName'] ?? json['building'] ?? '').toString().trim();
      final room = (json['roomName'] ?? json['room'] ?? '').toString().trim();
      final details = (json['areaDetails'] ?? json['locationDetails'] ?? '')
          .toString()
          .trim();
      final parts = <String>[];
      if (building.isNotEmpty) parts.add(building);
      if (room.isNotEmpty) parts.add('Room $room');
      if (details.isNotEmpty) parts.add(details);
      return parts.isEmpty ? 'Campus' : parts.join(' - ');
    }

    final requestId =
        asInt(json['id'] ?? json['requestId'] ?? json['supportRequestId']);
    final fallbackId = requestId?.toString() ??
        (json['ticketNo'] ?? json['code'] ?? '').toString();
    final area = (json['area'] ?? json['module'] ?? json['type'] ?? '')
        .toString()
        .toUpperCase();
    final created = asDate(
        json['createdAt'] ?? json['createdAtUtc'] ?? json['requestedAt']);
    final completed =
        asDate(json['completedAt'] ?? json['resolvedAt'] ?? json['closedAt']);

    return SupportTicket(
      requestId: requestId,
      id: fallbackId.isNotEmpty ? fallbackId : 'Unknown',
      title: (json['title'] ??
              json['subject'] ??
              json['issueTitle'] ??
              json['description'] ??
              'Support request')
          .toString(),
      description: (json['description'] ?? '').toString(),
      category: parseCategory(
          json['categoryName'] ?? json['category'] ?? json['categoryTag']),
      status: parseStatus(json['status']),
      priority: parsePriority(json['urgency'] ?? json['priority']),
      location: composeLocation(),
      createdAt: (created ?? DateTime.now()).toIso8601String(),
      assignedTo: (json['assignedToName'] ??
              json['staffName'] ??
              json['assignedStaffName'] ??
              json['assigneeName'])
          ?.toString(),
      completedAt: completed?.toIso8601String(),
      cancelledReason: json['cancelledReason']?.toString(),
      rating: asInt(json['rating']),
      type: area == 'FM' ? 'FM' : 'IT',
    );
  }

  String get statusString {
    switch (status) {
      case TicketStatus.pending:
        return 'Pending';
      case TicketStatus.assigned:
        return 'Assigned';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.completed:
        return 'Completed';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get priorityString {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
    }
  }

  String get categoryString {
    switch (category) {
      case TicketCategory.wifiNetwork:
        return 'Wi-Fi & Network';
      case TicketCategory.emailOffice365:
        return 'Email & Office 365';
      case TicketCategory.passwordReset:
        return 'Password Reset';
      case TicketCategory.projectorDisplay:
        return 'Projector/Display';
      case TicketCategory.printerScanner:
        return 'Printer/Scanner';
      case TicketCategory.softwareInstallation:
        return 'Software Installation';
      case TicketCategory.computerRepair:
        return 'Computer Repair';
      case TicketCategory.other:
        return 'Other';
    }
  }
}
