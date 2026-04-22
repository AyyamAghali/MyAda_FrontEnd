/// Response shape from POST /api/students/{id}/attendance/scan
class QrScanResult {
  final bool success;
  final String? errorCode;
  final String message;
  final String? studentId;
  final int? sessionId;
  final int? activationId;
  final int? validScanCount;
  /// Attendance round (e.g. 1 or 2) for this scan when applicable.
  final int? round;
  final String? status; // e.g. "Present", "Late"
  final DateTime? scannedAt;

  const QrScanResult({
    required this.success,
    this.errorCode,
    required this.message,
    this.studentId,
    this.sessionId,
    this.activationId,
    this.validScanCount,
    this.round,
    this.status,
    this.scannedAt,
  });

  factory QrScanResult.fromJson(Map<String, dynamic> json) {
    int? asInt(Object? v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return QrScanResult(
      success: json['success'] as bool? ?? false,
      errorCode: json['errorCode'] as String?,
      message: json['message'] as String? ?? '',
      studentId: json['studentId'] as String?,
      sessionId: asInt(json['sessionId']),
      activationId: asInt(json['activationId']),
      validScanCount: asInt(json['validScanCount']),
      round: asInt(json['round']),
      status: json['status'] as String?,
      scannedAt: json['scannedAt'] != null
          ? DateTime.tryParse(json['scannedAt'] as String)
          : null,
    );
  }
}
