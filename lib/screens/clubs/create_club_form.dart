import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/unified_photo_picker.dart';

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
  bool commitsToCode = false;

  // Step 4 fields
  String? logoPath;
  String? constitutionPath;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              'New Club Registration - Step ${_currentStep + 1} of 4',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.3,
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildInfoBox(
              title: 'Eligibility Requirements',
              color: Colors.blue,
              children: [
                'Only currently enrolled, active students can propose a new club',
                'Good academic standing required (no Honor Code violations)',
                'Minimum 2 core leaders (President & Vice President)',
                'Review existing clubs before applying',
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildWarningBox(
              title: 'Submission Deadline',
              text: 'Applications must be submitted by **September 30** Late submissions will not be considered.',
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 1,
            label: 'Proposed Club Name *',
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter your club name',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              onChanged: (value) => setState(() => clubName = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 2,
            label: 'Short Description of the Club *',
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Describe your club\'s mission, purpose, and focus areas...',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
              ),
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
              decoration: InputDecoration(
                hintText: 'Explain what makes your club different from existing clubs...',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
              ),
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
              decoration: InputDecoration(
                hintText: '1. Goal one\n2. Goal two\n3. Goal three',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
              ),
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
              decoration: InputDecoration(
                hintText: 'Example: Monthly workshops, guest speaker series, hackathons...',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'President Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 6,
            label: 'Full Name of President *',
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'First and Last Name',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              onChanged: (value) => setState(() => presidentName = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 7,
            label: 'ADA Email *',
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'student@ada.edu.az',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => setState(() => presidentEmail = value),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Program of Study *',
                  child: TextFormField(
                    decoration: InputDecoration(
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
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
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
                    decoration: InputDecoration(
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
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                    onChanged: (value) => setState(() => presidentGradYear = value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'Vice President Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 9,
            label: 'Full Name of Vice-President *',
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'First and Last Name',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              onChanged: (value) => setState(() => vicePresidentName = value),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedField(
            number: 0,
            label: 'ADA Email *',
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'student@ada.edu.az',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => setState(() => vicePresidentEmail = value),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Program of Study *',
                  child: TextFormField(
                    decoration: InputDecoration(
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
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
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
                    decoration: InputDecoration(
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
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
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
              decoration: InputDecoration(
                hintText: 'Name - Position - Email\nName - Position - Email',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNumberedField(
            number: 11,
            label: 'How does this club align with ADA University\'s mission and values? *',
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Explain how your club supports ADA\'s educational mission and core values...',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
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
              decoration: InputDecoration(
                hintText: 'Describe your club\'s vision for the next 3-5 years...',
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
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
              children: [
                RadioListTile<bool>(
                  title: const Text('Yes, I commit'),
                  value: true,
                  groupValue: commitsToCode,
                  onChanged: (value) => setState(() => commitsToCode = value!),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<bool>(
                  title: const Text('No'),
                  value: false,
                  groupValue: commitsToCode,
                  onChanged: (value) => setState(() => commitsToCode = value!),
                  contentPadding: EdgeInsets.zero,
                ),
                if (commitsToCode)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      'Thank you for your commitment to upholding ADA University\'s standards of academic integrity and student conduct.',
                      style: TextStyle(fontSize: 12, color: Colors.green.shade700),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildInfoBox(
              title: 'Required Documents',
              color: Colors.blue,
              children: [
                'Please upload your club logo and constitution document to complete your application.',
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 0,
            label: 'Club Logo *',
            child: UnifiedPhotoPicker(
              label: 'Upload Club Logo',
              icon: Icons.add_photo_alternate,
              height: 200,
              isFullWidth: false,
              backgroundColor: AppColors.gray100,
              onCameraSelected: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Club logo captured (mock).')),
                );
              },
              onPhotoSelected: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Club logo uploaded (mock).')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 0,
            label: 'Club Constitution *',
            subLabel: 'Upload a PDF document outlining your club\'s structure, bylaws, and operating procedures',
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, size: 48, color: AppColors.gray400),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload Constitution (PDF)',
                      style: TextStyle(fontSize: 14, color: AppColors.gray600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Max file size: 10MB',
                      style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildWarningBox(
              title: 'Review Before Submission',
              text: 'Please ensure all information is accurate. The Office of Student Services will contact you if any clarifications are needed.',
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

  Widget _buildInfoBox({
    required String title,
    required Color color,
    required List<String> children,
  }) {
    // Convert Color to MaterialColor shades
    Color getShade(int shade) {
      if (color == Colors.blue) {
        return Colors.blue[shade] ?? color;
      }
      // For other colors, use a simple approach
      return color;
    }

    final bgColor = color == Colors.blue ? Colors.blue.shade50 : color.withOpacity(0.1);
    final borderColor = color == Colors.blue ? Colors.blue.shade200 : color.withOpacity(0.3);
    final textColor = color == Colors.blue ? Colors.blue.shade900 : color;
    final itemColor = color == Colors.blue ? Colors.blue.shade700 : color.withOpacity(0.8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.6),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: (color == Colors.blue ? Colors.blue.shade100 : color.withOpacity(0.2)).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: textColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 12, color: itemColor)),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 11, color: itemColor, height: 1.3),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWarningBox({
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withOpacity(0.6),
        border: Border.all(color: Colors.orange.shade200.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade900,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.orange.shade700, height: 1.3),
          ),
        ],
      ),
    );
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
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: AppColors.gray300),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
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
                        content: const Text('Application submitted successfully!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep < 3 ? 'Continue >' : 'Submit Application',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

