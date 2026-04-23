import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/club_vacancy.dart';
import '../../services/club_api_service.dart';
import '../../utils/constants.dart';

class ApplyVacancyScreen extends StatefulWidget {
  final ClubVacancy vacancy;

  const ApplyVacancyScreen({super.key, required this.vacancy});

  @override
  State<ApplyVacancyScreen> createState() => _ApplyVacancyScreenState();
}

class _ApplyVacancyScreenState extends State<ApplyVacancyScreen> {
  final TextEditingController _purposeController = TextEditingController();
  final ClubApiService _api = ClubApiService();
  String? _attachedFileName;
  XFile? _attachedFile;
  bool _isSubmitting = false;

  static const int _minWords = 100;

  int get _wordCount {
    final text = _purposeController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  bool get _purposeValid => _wordCount >= _minWords;
  bool get _canSubmit => _purposeValid && _attachedFileName != null && !_isSubmitting;

  Future<void> _pickFile() async {
    // Simulate file selection for the prototype; in production use file_picker.
    setState(() {
      _attachedFileName = 'my_resume.pdf';
      _attachedFile = null;
    });
  }

  void _removeFile() => setState(() { _attachedFileName = null; _attachedFile = null; });

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
    try {
      await _api.applyToVacancy(
        vacancyId: widget.vacancy.id,
        purposeOfApplication: _purposeController.text.trim(),
        cvFile: _attachedFile,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(
          position: widget.vacancy.position,
          clubName: widget.vacancy.clubName,
          onDone: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      );
    } on ClubApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vacancy;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Apply for Position',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.gray200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Position summary card ───────────────────────────────
            _PositionCard(vacancy: v),
            const SizedBox(height: 20),
            // ── Purpose field ───────────────────────────────────────
            _SectionLabel(
              label: 'Purpose of Application',
              required: true,
            ),
            const SizedBox(height: 6),
            const Text(
              'Tell us why you\'re interested in this role and what makes you a great fit. Mention any relevant experience.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _purposeController,
              onChanged: (_) => setState(() {}),
              maxLines: 8,
              decoration: InputDecoration(
                hintText:
                    'I am passionate about this role because…',
                hintStyle: const TextStyle(
                    color: AppColors.gray400, fontSize: 14),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Word count indicator
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _purposeValid
                        ? const Color(0xFF22c55e)
                        : AppColors.gray300,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _purposeValid
                      ? '$_wordCount words — looks good!'
                      : '$_wordCount / $_minWords words minimum',
                  style: TextStyle(
                    fontSize: 12,
                    color: _purposeValid
                        ? const Color(0xFF22c55e)
                        : AppColors.gray400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ── CV upload ───────────────────────────────────────────
            _SectionLabel(label: 'CV / Resume', required: true),
            const SizedBox(height: 10),
            _attachedFileName == null
                ? _UploadArea(onTap: _pickFile)
                : _AttachedFile(
                    fileName: _attachedFileName!,
                    onRemove: _removeFile,
                  ),
            const SizedBox(height: 28),
            // ── Disclaimer ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gray200),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppColors.gray400),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All applications are reviewable by the club board. By submitting, you agree to share your profile and resume data.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24 + bottomPad),
          ],
        ),
      ),
      // ── Submit button ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _canSubmit ? () => _submit() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            disabledBackgroundColor: AppColors.gray200,
            foregroundColor: AppColors.white,
            disabledForegroundColor: AppColors.gray400,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Submit Application',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.send_outlined, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Sub-widgets
// ════════════════════════════════════════════════════════════════════

class _PositionCard extends StatelessWidget {
  final ClubVacancy vacancy;
  const _PositionCard({required this.vacancy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.work_outline,
                color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vacancy.position,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  vacancy.clubName,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _SectionLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Required',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _UploadArea extends StatelessWidget {
  final VoidCallback onTap;
  const _UploadArea({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.gray300,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.upload_file_outlined,
              size: 40,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap to upload your CV',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'PDF, DOC, DOCX — max 10 MB',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachedFile extends StatelessWidget {
  final String fileName;
  final VoidCallback onRemove;

  const _AttachedFile({required this.fileName, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22c55e), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              color: Color(0xFF22c55e), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.gray500),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── Success dialog ───────────────────────────────────────────────────
class _SuccessDialog extends StatelessWidget {
  final String position;
  final String clubName;
  final VoidCallback onDone;

  const _SuccessDialog({
    required this.position,
    required this.clubName,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF22c55e).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF22c55e),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Application Submitted!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your application for $position at $clubName has been received. The club board will review it and get back to you.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Back to Vacancies',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}