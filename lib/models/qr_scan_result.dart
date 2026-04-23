/// Response shape from POST /api/students/{id}/attendance/qr/scan
class QrScanResult {
  final bool success;
  final String? errorCode;
  final String message;
  final String? studentId;
  final int? sessionId;
  final int? activationId;
  final int? round;
  final int? validScanCount;
  final String? status; // e.g. "Present", "Late"
  final DateTime? scannedAt;

  const QrScanResult({
    required this.success,
    this.errorCode,
    required this.message,
    this.studentId,
    this.sessionId,
    this.activationId,
    this.round,
    this.validScanCount,
    this.status,
    this.scannedAt,
  });

  factory QrScanResult.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    final rawSuccess = json['success'];
    final success = rawSuccess is bool
        ? rawSuccess
        : rawSuccess?.toString().toLowerCase() == 'true';

    return QrScanResult(
      success: success,
      errorCode: json['errorCode']?.toString(),
      message: json['message']?.toString() ?? '',
      studentId: json['studentId']?.toString(),
      sessionId: asInt(json['sessionId']),
      activationId: asInt(json['activationId']),
      round: asInt(json['round']),
      validScanCount: asInt(json['validScanCount']),
      status: json['status']?.toString(),
      scannedAt: json['scannedAt'] != null
          ? DateTime.tryParse(json['scannedAt'].toString())
          : null,
    );
  }
}
