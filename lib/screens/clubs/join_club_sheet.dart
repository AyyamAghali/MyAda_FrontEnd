import 'package:flutter/material.dart';
import '../../models/club.dart';
import '../../services/club_api_service.dart';
import '../../utils/constants.dart';

/// Lightweight membership application — fields aligned with club join UX (letter, links, optional files).
class JoinClubSheet extends StatefulWidget {
  final Club club;

  const JoinClubSheet({super.key, required this.club});

  @override
  State<JoinClubSheet> createState() => _JoinClubSheetState();
}

class _JoinClubSheetState extends State<JoinClubSheet> {
  final _formKey = GlobalKey<FormState>();
  final _letterCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final ClubApiService _api = ClubApiService();
  bool _isSubmitting = false;

  InputDecoration _inputDeco([String? hint]) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 14),
    );
  }

  @override
  void dispose() {
    _letterCtrl.dispose();
    _portfolioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        number: 1,
                        label: 'Letter of Purpose',
                        isRequired: true,
                        child: TextFormField(
                          controller: _letterCtrl,
                          decoration: _inputDeco('Explain why you want to join this club and what you hope to contribute…'),
                          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                          maxLines: 6,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'This field is required.' : null,
                        ),
                      ),
                      _buildSection(
                        number: 2,
                        label: 'Any previous experience, works or portfolio links?',
                        child: TextFormField(
                          controller: _portfolioCtrl,
                          decoration: _inputDeco('https://example.com/portfolio'),
                          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                          keyboardType: TextInputType.url,
                        ),
                      ),
                      _buildSection(
                        number: 3,
                        label: 'Any previous works or portfolio files?',
                        subLabel: 'Optional',
                        child: _filePicker(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildSubmitBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900, size: 18),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join ${widget.club.name}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray900),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text('Membership application', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required int number,
    required String label,
    bool isRequired = false,
    String? subLabel,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900),
                    children: [
                      TextSpan(text: label),
                      if (isRequired)
                        const TextSpan(text: ' *', style: TextStyle(color: AppColors.secondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 2),
            Text(subLabel, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          ],
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _filePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File upload (mock) — ${widget.club.name}'))),
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.upload_file, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Upload files', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                      SizedBox(height: 2),
                      Text('Up to 10 files (mock)', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.gray400, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _isSubmitting = true);
                    try {
                      await _api.submitJoinApplication(
                        clubId: widget.club.id,
                        letterOfPurpose: _letterCtrl.text.trim(),
                        portfolioLinks: _portfolioCtrl.text.trim().isNotEmpty
                            ? _portfolioCtrl.text.trim()
                            : null,
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Application submitted successfully.')),
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
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                : const Text('Submit Application', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
