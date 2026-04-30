import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';

enum _ScanState { idle, processing, success, error }

class QrScannerScreen extends StatefulWidget {
  final bool embedded;

  const QrScannerScreen({super.key, this.embedded = false});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController? _cameraController;
  bool _cameraActive = false;
  bool _torchOn = false;

  _ScanState _state = _ScanState.idle;
  String _statusMessage = '';
  String? _scannedAt;
  String? _attendanceStatus;
  String? _lastDetectedPayload;
  DateTime? _lastDetectedAt;

  final _service = AttendanceService();

  bool get _canUseCamera {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  @override
  void initState() {
    super.initState();
    if (_canUseCamera) {
      _cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    }
    AuthService.instance.loadSession();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ── Camera ──────────────────────────────────────────────────────────────────

  void _startCamera() {
    if (!_canUseCamera || _cameraActive || _state == _ScanState.processing) {
      return;
    }
    setState(() {
      _cameraActive = true;
      _state = _ScanState.idle;
      _statusMessage = '';
    });
  }

  Future<void> _stopCamera() async {
    if (!_cameraActive) return;
    await _cameraController?.stop();
    if (mounted) setState(() => _cameraActive = false);
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_state == _ScanState.processing || !_cameraActive) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    final now = DateTime.now();
    if (_lastDetectedPayload == raw &&
        _lastDetectedAt != null &&
        now.difference(_lastDetectedAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastDetectedPayload = raw;
    _lastDetectedAt = now;

    _cameraController?.stop();
    setState(() => _cameraActive = false);
    _submit(raw);
  }

  Future<void> _toggleTorch() async {
    await _cameraController?.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit(String rawInput) async {
    if (_state == _ScanState.processing) return;

    setState(() {
      _state = _ScanState.processing;
      _statusMessage = 'Submitting attendance…';
      _scannedAt = null;
      _attendanceStatus = null;
    });

    try {
      final token = rawInput.trim();
      AttendanceService.validateToken(token);

      final studentId = AuthService.instance.studentId;
      if (studentId == null || studentId.isEmpty) {
        throw const AttendanceServiceException(
          message: 'Student id unavailable. Sign in again.',
        );
      }

      final result = await _service.submitQrScan(
        studentId: studentId,
        token: token,
      );

      if (mounted) {
        if (result.success) {
          setState(() {
            _state = _ScanState.success;
            _statusMessage = result.message;
            _attendanceStatus = result.status;
            _scannedAt = result.scannedAt != null ? _formatGmt4(result.scannedAt!) : null;
          });
        } else {
          setState(() {
            _state = _ScanState.error;
            _statusMessage = result.message;
          });
        }
      }
    } on AttendanceServiceException catch (e) {
      if (mounted) {
        setState(() {
          _state = _ScanState.error;
          _statusMessage = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _state = _ScanState.error;
          _statusMessage = 'Unexpected error. Please try again.';
        });
      }
    }
  }

  void _retryScan() {
    setState(() {
      _state = _ScanState.idle;
      _statusMessage = '';
      _scannedAt = null;
      _attendanceStatus = null;
    });
    if (_canUseCamera) _startCamera();
  }

  String _formatGmt4(DateTime dt) {
    final utc = dt.isUtc ? dt : dt.toUtc();
    final gmt4 = utc.add(const Duration(hours: 4));
    return '${DateFormat('MMM d, yyyy • h:mm a').format(gmt4)} (GMT+4)';
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_canUseCamera)
                      Expanded(child: _buildScannerArea(context))
                    else
                      Expanded(child: _buildNoCameraBanner()),
                    if (_state != _ScanState.idle) ...[
                      const SizedBox(height: 16),
                      _buildStatusCard(),
                    ],
                  ],
                ),
              ),
            ),
            if (_canUseCamera) _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          AppBackButton(
            onPressed: () async {
              await _stopCamera();
              if (mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Check-In',
                  style: AppTextStyles.moduleAppBarTitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Scanner Area ────────────────────────────────────────────────────────────

  Widget _buildScannerArea(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (_cameraActive)
              Positioned.fill(
                child: MobileScanner(
                  controller: _cameraController!,
                  onDetect: _onQrDetected,
                  errorBuilder: (_, error) => _buildCameraError(error),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap "Start Scanner" to begin',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ),

            // Corner guides
            if (_cameraActive)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: _CornerGuidesPainter(
                          color: _state == _ScanState.processing
                              ? Colors.white.withOpacity(0.35)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Gradient overlay
            if (_cameraActive)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

            // Torch button
            if (_cameraActive)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _toggleTorch,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _torchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

            // Bottom hint
            if (_cameraActive)
              Positioned(
                left: 0,
                right: 0,
                bottom: 14,
                child: Text(
                  _state == _ScanState.processing
                      ? 'Processing…'
                      : 'Point camera at the QR code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
    );
  }

  Widget _buildNoCameraBanner() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF3D7A96)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_2_rounded,
                size: 56, color: Colors.white.withOpacity(0.25)),
            const SizedBox(height: 14),
            Text(
              'Lesson attendance check-in',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'QR scanning is available in the mobile app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.75),
                height: 1.4,
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildCameraError(MobileScannerException error) {
    final String hint;
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      hint =
          'Camera access denied.\nEnable camera in Settings to scan your lesson QR code.';
    } else if (error.errorCode == MobileScannerErrorCode.unsupported) {
      hint = 'Camera not supported on this device.';
    } else {
      hint = 'Camera unavailable. Try closing other apps that use the camera.';
    }

    return Container(
      color: const Color(0xFF111827),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography_outlined,
              color: Colors.white38, size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => setState(() => _cameraActive = false),
            child: const Text('Back',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          if (error.errorCode == MobileScannerErrorCode.permissionDenied)
            TextButton(
              onPressed: openAppSettings,
              child: const Text('Open Settings',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  // ── Status Card ─────────────────────────────────────────────────────────────

  Widget _buildStatusCard() {
    if (_state == _ScanState.processing) {
      return Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Submitting attendance…',
            style: TextStyle(fontSize: 14, color: AppColors.gray600),
          ),
        ],
      );
    }

    final isSuccess = _state == _ScanState.success;
    final accentColor =
        isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final bgColor =
        isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final borderColor =
        isSuccess ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                size: 20,
                color: accentColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (isSuccess) ...[
            if (_attendanceStatus != null) ...[
              const SizedBox(height: 10),
              _buildResultDetail(
                  Icons.how_to_reg_outlined, 'Status', _attendanceStatus!),
            ],
            if (_scannedAt != null)
              _buildResultDetail(
                  Icons.access_time_outlined, 'Recorded at', _scannedAt!),
          ] else ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _state == _ScanState.processing ? null : _retryScan,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.gray500),
          const SizedBox(width: 6),
          Text('$label: ',
              style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Actions ──────────────────────────────────────────────────────────

  Widget _buildBottomActions() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding > 0 ? 0 : 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border:
            Border(top: BorderSide(color: AppColors.gray200.withOpacity(0.7))),
      ),
      child: _buildCameraActions(),
    );
  }

  Widget _buildCameraActions() {
    final isProcessing = _state == _ScanState.processing;

    Widget cameraBtn;
    if (isProcessing) {
      cameraBtn = OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
        ),
      );
    } else if (_cameraActive) {
      cameraBtn = OutlinedButton.icon(
        onPressed: _stopCamera,
        icon: const Icon(Icons.stop_circle_outlined, size: 17),
        label: const Text('Stop Scanner',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gray700,
          side: const BorderSide(color: AppColors.gray300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      cameraBtn = ElevatedButton.icon(
        onPressed: _startCamera,
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 17),
        label: const Text('Start Scanner',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: cameraBtn),
      ],
    );
  }
}

// ── Corner Guides Painter ─────────────────────────────────────────────────────

class _CornerGuidesPainter extends CustomPainter {
  final Color color;

  const _CornerGuidesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const arm = 24.0;
    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(0, arm), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(arm, 0), paint);
    canvas.drawLine(Offset(w - arm, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, arm), paint);
    canvas.drawLine(Offset(0, h - arm), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(arm, h), paint);
    canvas.drawLine(Offset(w - arm, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - arm), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(_CornerGuidesPainter old) => old.color != color;
}
