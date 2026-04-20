/// Response shape from POST /api/students/{id}/attendance/qr/scan
class QrScanResult {
  final bool success;
  final String? errorCode;
  final String message;
  final String? studentId;
  final int? sessionId;
  final int? activationId;
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
    this.validScanCount,
    this.status,
    this.scannedAt,
  });

  factory QrScanResult.fromJson(Map<String, dynamic> json) {
    return QrScanResult(
      success: json['success'] as bool? ?? false,
      errorCode: json['errorCode'] as String?,
      message: json['message'] as String? ?? '',
      studentId: json['studentId'] as String?,
      sessionId: json['sessionId'] as int?,
      activationId: json['activationId'] as int?,
      validScanCount: json['validScanCount'] as int?,
      status: json['status'] as String?,
      scannedAt: json['scannedAt'] != null
          ? DateTime.tryParse(json['scannedAt'] as String)
          : null,
    );
  }
}
