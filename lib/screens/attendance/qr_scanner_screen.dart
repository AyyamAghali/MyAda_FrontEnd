import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';

// ── Scan state ────────────────────────────────────────────────────────────────

enum _ScanState { idle, processing, success, error }

// ── Screen ────────────────────────────────────────────────────────────────────

/// Attendance QR scanner for students.
///
/// On Android/iOS/macOS: shows a live camera viewfinder plus a manual-entry
/// fallback (auto-shown if camera permission is denied).
///
/// On Windows/Linux: camera scanning is not available; manual entry is the
/// primary flow.
///
/// Navigation usage:
/// ```dart
/// Navigator.push(context,
///   MaterialPageRoute(builder: (_) => const QrScannerScreen()));
/// ```
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // ── Camera ───────────────────────────────────────────────────────────────
  // null on platforms where camera scanning is not supported.
  MobileScannerController? _cameraController;
  bool _cameraActive = false;
  bool _torchOn = false;

  // ── Scan state ───────────────────────────────────────────────────────────
  _ScanState _state = _ScanState.idle;
  String _statusMessage = '';
  String? _scannedAt;
  String? _attendanceStatus;
  String? _maskedToken; // shown in result, never the full token

  // ── UI toggles ───────────────────────────────────────────────────────────
  bool _manualExpanded = false;
  bool _studentIdExpanded = false;

  // ── Text controllers ─────────────────────────────────────────────────────
  final _manualTokenCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();

  // ── Service ──────────────────────────────────────────────────────────────
  final _service = AttendanceService();

  // ── Platform capability ──────────────────────────────────────────────────
  /// True on platforms where the camera scanner widget is supported.
  /// mobile_scanner supports: Android, iOS, macOS, Web.
  /// Windows and Linux fall back to manual-only input.
  bool get _canUseCamera {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (_canUseCamera) {
      _cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    }
    // Manual entry is expanded by default when camera isn't available.
    _manualExpanded = !_canUseCamera;
    // Eagerly load any persisted session so studentId is ready.
    AuthService.instance.loadSession();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _manualTokenCtrl.dispose();
    _studentIdCtrl.dispose();
    super.dispose();
  }

  // ── Camera control ────────────────────────────────────────────────────────

  void _startCamera() {
    if (!_canUseCamera || _cameraActive || _state == _ScanState.processing) {
      return;
    }
    setState(() {
      _cameraActive = true;
      // Clear previous result so the viewfinder feels fresh.
      _state = _ScanState.idle;
      _statusMessage = '';
    });
  }

  Future<void> _stopCamera() async {
    if (!_cameraActive) return;
    // Stop the underlying controller first, then remove the widget from the tree.
    await _cameraController?.stop();
    if (mounted) setState(() => _cameraActive = false);
  }

  void _onQrDetected(BarcodeCapture capture) {
    // Guard: drop duplicate callbacks while a request is already in-flight.
    if (_state == _ScanState.processing || !_cameraActive) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    // Remove the camera widget from the tree immediately to prevent further
    // callbacks, then fire the submit asynchronously.
    _cameraController?.stop();
    setState(() => _cameraActive = false);
    _submit(raw);
  }

  Future<void> _toggleTorch() async {
    await _cameraController?.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  // ── Submit flow ───────────────────────────────────────────────────────────

  Future<void> _submit(String rawInput) async {
    if (_state == _ScanState.processing) return;

    setState(() {
      _state = _ScanState.processing;
      _statusMessage = 'Submitting attendance…';
      _scannedAt = null;
      _attendanceStatus = null;
      _maskedToken = null;
    });

    try {
      // 1. Parse QR payload (JSON object or plain token string).
      final parsed = AttendanceService.parseQrPayload(rawInput);

      // 2. Validate token format before hitting the network.
      AttendanceService.validateToken(parsed.token);

      // Store masked version for the result card. Never store the full token.
      _maskedToken = _maskToken(parsed.token);

      // 3. Resolve student ID: explicit override > auth session > error.
      final override = _studentIdCtrl.text.trim();
      final studentId = override.isNotEmpty
          ? override
          : AuthService.instance.studentId;

      if (studentId == null || studentId.isEmpty) {
        throw const AttendanceServiceException(
          message: 'Student id unavailable. Sign in again.',
        );
      }

      final accessToken = AuthService.instance.accessToken ?? '';

      // 4. POST to backend.
      final result = await _service.submitQrScan(
        studentId: studentId,
        token: parsed.token,
        qrContext: parsed.qrContext,
        accessToken: accessToken,
      );

      if (mounted) {
        setState(() {
          _state = _ScanState.success;
          _statusMessage = result.message;
          _attendanceStatus = result.status;
          _scannedAt = result.scannedAt != null
              ? DateFormat('MMM d, yyyy • h:mm a').format(result.scannedAt!)
              : null;
        });
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

  // Shows first 4 + bullets + last 4 chars; never exposes the full token in UI.
  String _maskToken(String token) {
    if (token.length <= 8) return '•' * token.length;
    return '${token.substring(0, 4)}••••${token.substring(token.length - 4)}';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: false,
        child: ResponsiveContainer(
          backgroundColor: AppColors.white,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroArea(context),
                      _buildTitleSection(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_state != _ScanState.idle) ...[
                              _buildStatusSection(),
                              _buildDivider(),
                            ],
                            _buildManualEntrySection(),
                            _buildDivider(),
                            _buildStudentIdSection(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero area ─────────────────────────────────────────────────────────────

  Widget _buildHeroArea(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return _canUseCamera
        ? _buildCameraHero(topPadding)
        : _buildBannerHero(context, topPadding);
  }

  Widget _buildCameraHero(double topPadding) {
    return Stack(
      children: [
        // ── Camera / placeholder ────────────────────────────────────────
        Container(
          width: double.infinity,
          height: 320 + topPadding,
          decoration: const BoxDecoration(
            color: Color(0xFF111827),
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _cameraActive
              ? MobileScanner(
                  controller: _cameraController!,
                  onDetect: _onQrDetected,
                  errorBuilder: (_, error) => _buildCameraError(error),
                )
              : Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 72,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
        ),

        // ── Gradient overlay (top + bottom readability) ─────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.35),
                  ],
                  stops: const [0.0, 0.25, 0.72, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ── Back button ─────────────────────────────────────────────────
        Positioned(
          top: topPadding + 8,
          left: 16,
          child: _CircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () async {
              await _stopCamera();
              if (mounted) Navigator.pop(context);
            },
          ),
        ),

        // ── Torch toggle (visible while camera is live) ─────────────────
        if (_cameraActive)
          Positioned(
            top: topPadding + 8,
            right: 16,
            child: _CircleButton(
              icon: _torchOn
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
              onTap: _toggleTorch,
            ),
          ),

        // ── Corner guides overlay ───────────────────────────────────────
        if (_cameraActive)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
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

        // ── Bottom hint ─────────────────────────────────────────────────
        if (_cameraActive)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Text(
              _state == _ScanState.processing
                  ? 'Processing…'
                  : 'Point camera at the QR code',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// Fallback hero used on Windows / Linux where camera scanning is unavailable.
  Widget _buildBannerHero(BuildContext context, double topPadding) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 170 + topPadding,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.18),
              ),
            ),
          ),
        ),
        Positioned(
          top: topPadding + 8,
          left: 16,
          child: _CircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          left: 20,
          bottom: 18,
          child: _HeroChip(label: 'Manual Entry'),
        ),
      ],
    );
  }

  /// Shown inside the camera view when permissions are denied or device
  /// doesn't support scanning. Offers a one-tap fallback to manual entry.
  Widget _buildCameraError(MobileScannerException error) {
    final String hint;
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      hint =
          'Camera access denied.\nEnable the permission in Settings or use manual entry.';
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
              color: Colors.white38, size: 52),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() {
              _cameraActive = false;
              _manualExpanded = true;
            }),
            child: const Text('Use Manual Entry',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Title section ─────────────────────────────────────────────────────────

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATTENDANCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _canUseCamera ? 'Scan QR Code' : 'Enter Attendance Token',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _canUseCamera
                ? 'Scan the QR code shown by your instructor, or enter the token manually.'
                : 'Enter the attendance token displayed by your instructor.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status / result section ───────────────────────────────────────────────

  Widget _buildStatusSection() {
    // Processing spinner row.
    if (_state == _ScanState.processing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Submitting attendance…',
              style: TextStyle(fontSize: 14, color: AppColors.gray600),
            ),
          ],
        ),
      );
    }

    final isSuccess = _state == _ScanState.success;
    final accentColor = isSuccess
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
    final bgColor =
        isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final borderColor =
        isSuccess ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Headline row ──────────────────────────────────────────────
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

          // ── Detail rows (success only) ────────────────────────────────
          if (isSuccess) ...[
            if (_attendanceStatus != null) ...[
              const SizedBox(height: 10),
              _buildResultDetail(
                Icons.how_to_reg_outlined,
                'Status',
                _attendanceStatus!,
              ),
            ],
            if (_scannedAt != null)
              _buildResultDetail(
                Icons.access_time_outlined,
                'Recorded at',
                _scannedAt!,
              ),
            if (_maskedToken != null)
              _buildResultDetail(
                Icons.token_outlined,
                'Token',
                _maskedToken!,
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
              style: const TextStyle(
                  fontSize: 13, color: AppColors.gray500)),
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

  // ── Manual entry section ──────────────────────────────────────────────────

  Widget _buildManualEntrySection() {
    // On Windows / Linux the section is always expanded; toggle is hidden.
    final canCollapse = _canUseCamera;
    final isExpanded = _manualExpanded || !canCollapse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────────────
        GestureDetector(
          onTap: canCollapse
              ? () => setState(() => _manualExpanded = !_manualExpanded)
              : null,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              const Text(
                'Enter Token Manually',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              if (canCollapse)
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gray400,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),

        // ── Collapsible token field ───────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextField(
              controller: _manualTokenCtrl,
              enabled: _state != _ScanState.processing,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray900,
              ),
              decoration: _inputDecoration(
                hint: 'Paste or type attendance token',
                prefixIcon: Icons.token_outlined,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Student ID override section ───────────────────────────────────────────

  Widget _buildStudentIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () =>
              setState(() => _studentIdExpanded = !_studentIdExpanded),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              const Text(
                'Student ID Override',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              AnimatedRotation(
                turns: _studentIdExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.gray400,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: _studentIdExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Leave blank to use your signed-in account. '
                'Provide a GUID only when testing or acting on behalf of another user.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.gray500, height: 1.5),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _studentIdCtrl,
                enabled: _state != _ScanState.processing,
                decoration: _inputDecoration(
                  hint: 'Student GUID (optional)',
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: AppColors.gray200, height: 1),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(fontSize: 14, color: AppColors.gray400),
      prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.gray400),
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
              top: BorderSide(color: AppColors.gray200, width: 1)),
        ),
        child: _canUseCamera
            ? _buildCameraBottomBar()
            : _buildManualOnlyBottomBar(),
      ),
    );
  }

  /// Bottom bar for camera-capable platforms.
  /// Left button toggles the scanner; right button submits a typed token
  /// (appears only when the manual field has content).
  Widget _buildCameraBottomBar() {
    final isProcessing = _state == _ScanState.processing;

    Widget cameraButton;
    if (isProcessing) {
      // Disabled state while request is in-flight.
      cameraButton = OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary)),
        ),
      );
    } else if (_cameraActive) {
      cameraButton = OutlinedButton.icon(
        onPressed: _stopCamera,
        icon: const Icon(Icons.stop_circle_outlined, size: 17),
        label: const Text('Stop Scanner',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gray700,
          side: const BorderSide(color: AppColors.gray300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      cameraButton = ElevatedButton.icon(
        onPressed: _startCamera,
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 17),
        label: const Text('Start Scanner',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: cameraButton),
        // Submit button appears only when a manual token has been typed.
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Bottom bar for Windows / Linux: single full-width submit button.
  Widget _buildManualOnlyBottomBar() {
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : const Icon(Icons.check_circle_outline_rounded, size: 17),
        label: const Text('Submit Attendance',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Private helper widgets
// ══════════════════════════════════════════════════════════════════════════════

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;

  const _HeroChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Draws the four corner L-shaped guides inside the scan region.
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

    // Top-left
    canvas.drawLine(Offset(0, arm), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(arm, 0), paint);
    // Top-right
    canvas.drawLine(Offset(w - arm, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, arm), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, h - arm), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(arm, h), paint);
    // Bottom-right
    canvas.drawLine(Offset(w - arm, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - arm), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(_CornerGuidesPainter old) => old.color != color;
}
