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
  final String type; // 'IT' or 'Technical'

  SupportTicket({
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

