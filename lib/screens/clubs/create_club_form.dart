import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';

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
  /// `null` = not answered yet; must be `true` to continue past step 3.
  bool? honorCommitment;

  // Step 4 fields
  String? logoPath;
  String? constitutionPath;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  InputDecoration _clubInputDecoration([String? hint]) {
    return InputDecoration(
      hintText: (hint != null && hint.isNotEmpty) ? hint : null,
      filled: true,
      fillColor: AppColors.white,
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: AppColors.gray400.withValues(alpha: 0.85), fontSize: 14),
    );
  }

  void _showImageSourceSheet({
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 20),
                  ),
                  title: const Text('Take photo', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onCamera();
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.photo_library, color: AppColors.primary, size: 20),
                  ),
                  title: const Text('Choose from library', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onGallery();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: AppColors.backgroundLight,
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.white,
      width: double.infinity,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900, size: 18),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'New Club Registration · Step ${_currentStep + 1} of 4',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                title: const Text(
                  'Eligibility requirements',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                subtitle: Text(
                  'Who can apply · what you need',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
                children: const [
                  _EligibilityLine(
                    'Only currently enrolled, active students can propose a new club.',
                  ),
                  _EligibilityLine(
                    'Good academic standing required (no Honor Code violations).',
                  ),
                  _EligibilityLine(
                    'Minimum two core leaders (President and Vice President).',
                  ),
                  _EligibilityLine(
                    'Review existing clubs before applying.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildNumberedField(
            number: 1,
            label: 'Proposed Club Name *',
            child: TextFormField(
              decoration: _clubInputDecoration('Enter your club name'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              onChanged: (value) => setState(() => clubName = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 2,
            label: 'Short Description of the Club *',
            child: TextFormField(
              decoration: _clubInputDecoration('Describe your club\'s mission, purpose, and focus areas…'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 4,
              maxLength: 500,
              onChanged: (value) => setState(() => description = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 3,
            label: 'What makes this club unique? *',
            subLabel: 'Compared to existing clubs',
            child: TextFormField(
              decoration: _clubInputDecoration('Explain what makes your club different from existing clubs…'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 3,
              onChanged: (value) => setState(() => uniqueness = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 4,
            label: 'Main goals and objectives *',
            subLabel: 'For this academic year (provide at least 3)',
            child: TextFormField(
              decoration: _clubInputDecoration('1. Goal one\n2. Goal two\n3. Goal three'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 4,
              onChanged: (value) => setState(() => goals = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 5,
            label: 'Proposed activities/events *',
            subLabel: 'Give specific examples',
            child: TextFormField(
              decoration: _clubInputDecoration(
                'Example: Monthly workshops, guest speaker series, hackathons…',
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 3,
              onChanged: (value) => setState(() => activities = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'President',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.02,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildNumberedField(
            number: 6,
            label: 'Full Name of President *',
            child: TextFormField(
              decoration: _clubInputDecoration('First and Last Name'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              onChanged: (value) => setState(() => presidentName = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 7,
            label: 'ADA Email *',
            child: TextFormField(
              decoration: _clubInputDecoration('student@ada.edu.az'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => setState(() => presidentEmail = value),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Program of Study *',
                  child: TextFormField(
                    decoration: _clubInputDecoration(),
                    style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                    onChanged: (value) => setState(() => presidentProgram = value),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Graduation Year *',
                  child: TextFormField(
                    decoration: _clubInputDecoration(),
                    style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                    onChanged: (value) => setState(() => presidentGradYear = value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Vice President',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.02,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildNumberedField(
            number: 9,
            label: 'Full Name of Vice-President *',
            child: TextFormField(
              decoration: _clubInputDecoration('First and Last Name'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              onChanged: (value) => setState(() => vicePresidentName = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 0,
            label: 'ADA Email *',
            child: TextFormField(
              decoration: _clubInputDecoration('student@ada.edu.az'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => setState(() => vicePresidentEmail = value),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Program of Study *',
                  child: TextFormField(
                    decoration: _clubInputDecoration(),
                    style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                    onChanged: (value) => setState(() => vicePresidentProgram = value),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Graduation Year *',
                  child: TextFormField(
                    decoration: _clubInputDecoration(),
                    style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                    onChanged: (value) => setState(() => vicePresidentGradYear = value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 10,
            label: 'Other Core Executive Members',
            subLabel: 'List additional founding members (optional)',
            child: TextFormField(
              decoration: _clubInputDecoration('Name — Position — Email'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 4,
              onChanged: (value) => setState(() => otherMembers = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNumberedField(
            number: 11,
            label: 'How does this club align with ADA University\'s mission and values? *',
            child: TextFormField(
              decoration: _clubInputDecoration(
                'Explain how your club supports ADA\'s educational mission and core values…',
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 4,
              onChanged: (value) => setState(() => alignment = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 12,
            label: 'What is the long-term vision of the club? *',
            child: TextFormField(
              decoration: _clubInputDecoration(
                'Describe your club\'s vision for the next 3–5 years…',
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              maxLines: 4,
              onChanged: (value) => setState(() => vision = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 13,
            label: 'Do you commit to following ADA\'s Honor Code, Code of Conduct, and Student Club Policy regulations?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<bool?>(
                  title: const Text('Yes, I commit'),
                  value: true,
                  groupValue: honorCommitment,
                  onChanged: (bool? value) => setState(() => honorCommitment = value),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
                RadioListTile<bool?>(
                  title: const Text('No'),
                  value: false,
                  groupValue: honorCommitment,
                  onChanged: (bool? value) => setState(() => honorCommitment = value),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
                if (honorCommitment == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Thank you — your commitment is recorded with this application.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.primary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNumberedField(
            number: 0,
            label: 'Club Logo *',
            child: _buildElegantLogoPicker(),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 0,
            label: 'Club Constitution *',
            subLabel:
                'PDF outlining your club\'s structure, bylaws, and operating procedures',
            child: _buildConstitutionPicker(),
          ),
          const SizedBox(height: 20),
          _buildReviewHint(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildElegantLogoPicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showImageSourceSheet(
          onCamera: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Club logo captured (mock).')),
            );
          },
          onGallery: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Club logo uploaded (mock).')),
            );
          },
        ),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add club logo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap to choose or take a photo · PNG or JPG · min. 200×200 px',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConstitutionPicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: AppColors.primary.withValues(alpha: 0.9),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Constitution (PDF)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to upload · max. 10 MB',
                        style: TextStyle(fontSize: 13, color: AppColors.gray500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.gray400, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.fact_check_outlined,
            size: 22,
            color: AppColors.primary.withValues(alpha: 0.75),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Take a moment to confirm your answers. Student Services may follow up if anything needs clarification.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedField({
    required int number,
    required String label,
    String? subLabel,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        if (number > 0)
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
            letterSpacing: -0.2,
          ),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
        ],
        const SizedBox(height: 10),
        child,
        ],
      ),
    );
  }

  void _onPrimaryPressed() {
    if (_currentStep == 2) {
      if (honorCommitment != true) {
        final msg = honorCommitment == false
            ? 'You must agree to ADA policies to register a club.'
            : 'Please answer the honor code question to continue.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
        return;
      }
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

  Widget _buildBottomButtons(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep--);
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.gray200),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _onPrimaryPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _currentStep < 3
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.outbox_rounded, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Submit registration',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EligibilityLine extends StatelessWidget {
  final String text;

  const _EligibilityLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

