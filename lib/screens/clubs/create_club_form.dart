import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CreateClubForm extends StatefulWidget {
  const CreateClubForm({super.key});

  @override
  State<CreateClubForm> createState() => _CreateClubFormState();
}

class _CreateClubFormState extends State<CreateClubForm> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Step 1 fields
  String clubName = '';
  String description = '';
  String uniqueness = '';
  String goals = '';
  String activities = '';

  // Step 2 fields
  String presidentName = '';
  String presidentEmail = '';
  String presidentProgram = '';
  String presidentGradYear = '';
  String vicePresidentName = '';
  String vicePresidentEmail = '';
  String vicePresidentProgram = '';
  String vicePresidentGradYear = '';
  String otherMembers = '';

  // Step 3 fields
  String alignment = '';
  String vision = '';
  bool? honorCommitment;

  // Step 4 fields
  String? logoPath;
  String? constitutionPath;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (clubName.trim().isEmpty) return 'Club name is required.';
        if (description.trim().isEmpty) return 'Club description is required.';
        if (uniqueness.trim().isEmpty) return 'Uniqueness is required.';
        if (goals.trim().isEmpty) return 'Goals are required.';
        if (activities.trim().isEmpty) return 'Activities are required.';
        return null;
      case 1:
        if (presidentName.trim().isEmpty) return 'President name is required.';
        if (presidentEmail.trim().isEmpty) return 'President email is required.';
        if (presidentProgram.trim().isEmpty) return 'President program is required.';
        if (presidentGradYear.trim().isEmpty) return 'President grad year is required.';
        if (vicePresidentName.trim().isEmpty) return 'Vice-President name is required.';
        if (vicePresidentEmail.trim().isEmpty) return 'Vice-President email is required.';
        if (vicePresidentProgram.trim().isEmpty) return 'Vice-President program is required.';
        if (vicePresidentGradYear.trim().isEmpty) return 'Vice-President grad year is required.';
        return null;
      case 2:
        if (alignment.trim().isEmpty) return 'Alignment with ADA mission is required.';
        if (vision.trim().isEmpty) return 'Long-term vision is required.';
        if (honorCommitment == null) return 'Please answer the honor code question.';
        if (honorCommitment == false) return 'You must agree to ADA policies to register a club.';
        return null;
      default:
        return null;
    }
  }

  void _onContinue() {
    final err = _validateStep(_currentStep);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      return;
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Application submitted successfully.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _onBack() {
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
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
                const Text(
                  'New Club Registration',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of 4',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      color: AppColors.white,
      width: double.infinity,
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSubmissionDeadlineBannerCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: AppColors.secondary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Submission deadline', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white.withValues(alpha: 0.9), letterSpacing: 0.4)),
                const Text('May 15, 2026', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('39 days left', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Club info ─────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubmissionDeadlineBannerCompact(),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                title: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Text(
                      'Eligibility requirements',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
                children: const [
                  _BulletLine('Only currently enrolled, active students can propose a new club.'),
                  _BulletLine('Good academic standing required (no Honor Code violations).'),
                  _BulletLine('Minimum two core leaders (President and Vice President).'),
                  _BulletLine('Review existing clubs before applying.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            number: 1,
            label: 'Proposed Club Name',
            required: true,
            child: TextFormField(
              decoration: _inputDeco('Enter your club name'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              onChanged: (v) => setState(() => clubName = v),
            ),
          ),
          _buildSection(
            number: 2,
            label: 'Short Description',
            required: true,
            child: TextFormField(
              decoration: _inputDeco('Describe your club\'s mission, purpose, and focus areas…'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 4,
              maxLength: 500,
              onChanged: (v) => setState(() => description = v),
            ),
          ),
          _buildSection(
            number: 3,
            label: 'What makes this club unique?',
            required: true,
            subLabel: 'Compared to existing clubs',
            child: TextFormField(
              decoration: _inputDeco('Explain what makes your club different…'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 3,
              onChanged: (v) => setState(() => uniqueness = v),
            ),
          ),
          _buildSection(
            number: 4,
            label: 'Main goals and objectives',
            required: true,
            subLabel: 'For this academic year (at least 3)',
            child: TextFormField(
              decoration: _inputDeco('1. Goal one\n2. Goal two\n3. Goal three'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 4,
              onChanged: (v) => setState(() => goals = v),
            ),
          ),
          _buildSection(
            number: 5,
            label: 'Proposed activities/events',
            required: true,
            subLabel: 'Give specific examples',
            child: TextFormField(
              decoration: _inputDeco('Monthly workshops, guest speaker series, hackathons…'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 3,
              onChanged: (v) => setState(() => activities = v),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Leadership ────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('President'),
          const SizedBox(height: 8),
          _buildSection(number: 6, label: 'Full Name', required: true, child: TextFormField(
            decoration: _inputDeco('First and Last Name'),
            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
            onChanged: (v) => setState(() => presidentName = v),
          )),
          _buildSection(number: 7, label: 'ADA Email', required: true, child: TextFormField(
            decoration: _inputDeco('student@ada.edu.az'),
            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => setState(() => presidentEmail = v),
          )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildSection(number: 0, label: 'Program', required: true, child: TextFormField(
                decoration: _inputDeco(),
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                onChanged: (v) => setState(() => presidentProgram = v),
              ))),
              const SizedBox(width: 10),
              Expanded(child: _buildSection(number: 0, label: 'Grad Year', required: true, child: TextFormField(
                decoration: _inputDeco(),
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                onChanged: (v) => setState(() => presidentGradYear = v),
              ))),
            ],
          ),
          const SizedBox(height: 12),
          _sectionHeading('Vice President'),
          const SizedBox(height: 8),
          _buildSection(number: 9, label: 'Full Name', required: true, child: TextFormField(
            decoration: _inputDeco('First and Last Name'),
            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
            onChanged: (v) => setState(() => vicePresidentName = v),
          )),
          _buildSection(number: 0, label: 'ADA Email', required: true, child: TextFormField(
            decoration: _inputDeco('student@ada.edu.az'),
            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => setState(() => vicePresidentEmail = v),
          )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildSection(number: 0, label: 'Program', required: true, child: TextFormField(
                decoration: _inputDeco(),
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                onChanged: (v) => setState(() => vicePresidentProgram = v),
              ))),
              const SizedBox(width: 10),
              Expanded(child: _buildSection(number: 0, label: 'Grad Year', required: true, child: TextFormField(
                decoration: _inputDeco(),
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                onChanged: (v) => setState(() => vicePresidentGradYear = v),
              ))),
            ],
          ),
          _buildSection(number: 10, label: 'Other Core Executive Members', subLabel: 'Optional', child: TextFormField(
            decoration: _inputDeco('Name — Position — Email'),
            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
            maxLines: 4,
            onChanged: (v) => setState(() => otherMembers = v),
          )),
        ],
      ),
    );
  }

  // ── Step 3: Mission & Commitment ──────────────────────────────────
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            number: 11,
            label: 'Alignment with ADA\'s mission and values',
            required: true,
            child: TextFormField(
              decoration: _inputDeco('Explain how your club supports ADA\'s mission…'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 4,
              onChanged: (v) => setState(() => alignment = v),
            ),
          ),
          _buildSection(
            number: 12,
            label: 'Long-term vision',
            required: true,
            child: TextFormField(
              decoration: _inputDeco('Describe your club\'s vision for the next 3–5 years…'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 4,
              onChanged: (v) => setState(() => vision = v),
            ),
          ),
          _buildSection(
            number: 13,
            label: 'Honor Code, Code of Conduct, Student Club Policy commitment',
            required: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<bool?>(
                  title: const Text('Yes, I commit'),
                  value: true,
                  groupValue: honorCommitment,
                  onChanged: (v) => setState(() => honorCommitment = v),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  dense: true,
                ),
                RadioListTile<bool?>(
                  title: const Text('No'),
                  value: false,
                  groupValue: honorCommitment,
                  onChanged: (v) => setState(() => honorCommitment = v),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  dense: true,
                ),
                if (honorCommitment == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Thank you — your commitment is recorded with this application.',
                      style: TextStyle(fontSize: 13, height: 1.35, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (honorCommitment == false)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'You must agree to continue with registration.',
                      style: TextStyle(fontSize: 13, height: 1.35, color: Colors.red.shade700, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Documents ─────────────────────────────────────────────
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('Documents'),
          const SizedBox(height: 12),
          _buildSection(
            number: 0,
            label: 'Club Logo',
            required: true,
            child: _filePicker(
              icon: Icons.add_photo_alternate_outlined,
              title: 'Upload club logo',
              subtitle: 'PNG or JPG · min. 200×200 px',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Club logo uploaded (mock).')),
                );
              },
            ),
          ),
          _buildSection(
            number: 0,
            label: 'Club Constitution',
            required: true,
            subLabel: 'PDF outlining structure, bylaws, and procedures',
            child: _filePicker(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Upload constitution (PDF)',
              subtitle: 'Max file size: 10 MB',
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.fact_check_outlined, size: 20, color: AppColors.gray500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please double-check your answers before submitting. Student Services may follow up if clarification is needed.',
                  style: TextStyle(fontSize: 13, height: 1.45, color: AppColors.gray500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filePicker({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
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

  // ── Shared helpers ────────────────────────────────────────────────

  Widget _sectionHeading(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.person_outline, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray900)),
      ],
    );
  }

  Widget _buildSection({
    required int number,
    required String label,
    bool required = false,
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
              if (number > 0) ...[
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
              ],
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900),
                    children: [
                      TextSpan(text: label),
                      if (required)
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

  Widget _buildBottomButtons(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: AppColors.gray200),
                  ),
                  child: const Text('Back', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton(
                onPressed: _onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep < 3 ? 'Continue' : 'Submit',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  const _BulletLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.gray700)),
          ),
        ],
      ),
    );
  }
}
