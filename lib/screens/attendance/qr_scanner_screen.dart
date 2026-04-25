import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

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
  int? _round;
  int? _validScanCount;
  String? _maskedToken;
  String? _lastDetectedPayload;
  DateTime? _lastDetectedAt;

  bool _manualExpanded = false;

  final _manualTokenCtrl = TextEditingController();
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
    _manualExpanded = !_canUseCamera;
    AuthService.instance.loadSession();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _manualTokenCtrl.dispose();
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
      _round = null;
      _validScanCount = null;
      _maskedToken = null;
    });

    try {
      final token = rawInput.trim();
      AttendanceService.validateToken(token);
      _maskedToken = _maskToken(token);

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
            _round = result.round;
            _validScanCount = result.validScanCount;
            _scannedAt = result.scannedAt != null
                ? DateFormat('MMM d, yyyy • h:mm a').format(result.scannedAt!)
                : null;
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

  Future<void> _submitManual() async {
    final token = _manualTokenCtrl.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an attendance token.'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    await _submit(token);
  }

  void _retryScan() {
    setState(() {
      _state = _ScanState.idle;
      _statusMessage = '';
      _scannedAt = null;
      _attendanceStatus = null;
      _round = null;
      _validScanCount = null;
      _maskedToken = null;
    });
    if (_canUseCamera) _startCamera();
  }

  String _maskToken(String token) {
    if (token.length <= 8) return '•' * token.length;
    return '${token.substring(0, 4)}••••${token.substring(token.length - 4)}';
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    if (_canUseCamera) _buildScannerArea(context),
                    if (!_canUseCamera) _buildNoCameraBanner(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_state != _ScanState.idle) ...[
                            const SizedBox(height: 20),
                            _buildStatusCard(),
                          ],
                          const SizedBox(height: 20),
                          _buildManualEntrySection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
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
          GestureDetector(
            onTap: () async {
              await _stopCamera();
              if (mounted) Navigator.pop(context);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppColors.gray700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Check-in',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _canUseCamera
                      ? 'Scan QR code or enter token manually'
                      : 'Enter the attendance token',
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.gray500),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 280,
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
      ),
    );
  }

  Widget _buildNoCameraBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF3D7A96)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.qr_code_2_rounded,
                size: 56, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 10),
            Text(
              'Enter token below',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraError(MobileScannerException error) {
    final String hint;
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      hint = 'Camera access denied.\nEnable in Settings or use manual entry.';
    } else if (error.errorCode == MobileScannerErrorCode.unsupported) {
      hint = 'Camera not supported on this device.';
    } else {
      hint = 'Camera unavailable. Use manual entry below.';
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
            onPressed: () => setState(() {
              _cameraActive = false;
              _manualExpanded = true;
            }),
            child: const Text('Use Manual Entry',
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
            if (_round != null)
              _buildResultDetail(
                  Icons.repeat_outlined, 'Round', _round.toString()),
            if (_validScanCount != null)
              _buildResultDetail(Icons.confirmation_num_outlined,
                  'Valid scans', _validScanCount.toString()),
            if (_maskedToken != null)
              _buildResultDetail(
                  Icons.token_outlined, 'Token', _maskedToken!),
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

  // ── Manual Entry ────────────────────────────────────────────────────────────

  Widget _buildManualEntrySection() {
    final canCollapse = _canUseCamera;
    final isExpanded = _manualExpanded || !canCollapse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: canCollapse
              ? () => setState(() => _manualExpanded = !_manualExpanded)
              : null,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.keyboard_rounded,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              const Text(
                'Manual Token Entry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const Spacer(),
              if (canCollapse)
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gray400, size: 22),
                ),
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextField(
              controller: _manualTokenCtrl,
              enabled: _state != _ScanState.processing,
              maxLines: 1,
              style: const TextStyle(fontSize: 14, color: AppColors.gray900),
              decoration: InputDecoration(
                hintText: 'Paste or type attendance token',
                hintStyle:
                    const TextStyle(fontSize: 14, color: AppColors.gray400),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 10),
                  child:
                      Icon(Icons.token_outlined, size: 18, color: AppColors.gray400),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
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
      child: _canUseCamera ? _buildCameraActions() : _buildManualActions(),
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
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _manualTokenCtrl,
          builder: (_, value, __) {
            if (value.text.trim().isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: ElevatedButton(
                onPressed: isProcessing ? null : _submitManual,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildManualActions() {
    final isProcessing = _state == _ScanState.processing;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : _submitManual,
        icon: isProcessing
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : const Icon(Icons.check_circle_outline_rounded, size: 17),
        label: const Text('Submit Attendance',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
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
