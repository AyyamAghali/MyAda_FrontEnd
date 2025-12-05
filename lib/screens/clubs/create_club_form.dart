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
      padding: const EdgeInsets.all(24),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'New Club Registration - Step ${_currentStep + 1} of 4',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.white,
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBox(
            title: 'Eligibility Requirements',
            color: Colors.blue,
            children: [
              'Only currently enrolled, active students can propose a new club',
              'Good academic standing required (no Honor Code violations)',
              'Minimum 2 core leaders (President & Vice President)',
              'Review existing clubs before applying',
            ],
          ),
          const SizedBox(height: 16),
          _buildWarningBox(
            title: 'Submission Deadline',
            text: 'Applications must be submitted by **September 30** Late submissions will not be considered.',
          ),
          const SizedBox(height: 24),
          _buildNumberedField(
            number: 1,
            label: 'Proposed Club Name *',
            child: TextFormField(
              decoration: const InputDecoration(hintText: 'Enter your club name'),
              onChanged: (value) => setState(() => clubName = value),
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 2,
            label: 'Short Description of the Club *',
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Describe your club\'s mission, purpose, and focus areas...',
              ),
              maxLines: 4,
              maxLength: 500,
              onChanged: (value) => setState(() => description = value),
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 3,
            label: 'What makes this club unique? *',
            subLabel: 'Compared to existing clubs',
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Explain what makes your club different from existing clubs...',
              ),
              maxLines: 3,
              onChanged: (value) => setState(() => uniqueness = value),
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 4,
            label: 'Main goals and objectives *',
            subLabel: 'For this academic year (provide at least 3)',
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: '1. Goal one\n2. Goal two\n3. Goal three',
              ),
              maxLines: 4,
              onChanged: (value) => setState(() => goals = value),
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 5,
            label: 'Proposed activities/events *',
            subLabel: 'Give specific examples',
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Example: Monthly workshops, guest speaker series, hackathons...',
              ),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'President Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 6,
            label: 'Full Name of President *',
            child: TextFormField(
              decoration: const InputDecoration(hintText: 'First and Last Name'),
              onChanged: (value) => setState(() => presidentName = value),
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 7,
            label: 'ADA Email *',
            child: TextFormField(
              decoration: const InputDecoration(hintText: 'student@ada.edu.az'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => setState(() => presidentEmail = value),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Program of Study *',
                  child: TextFormField(
                    onChanged: (value) => setState(() => presidentProgram = value),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Graduation Year *',
                  child: TextFormField(
                    onChanged: (value) => setState(() => presidentGradYear = value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Vice President Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 9,
            label: 'Full Name of Vice-President *',
            child: TextFormField(
              decoration: const InputDecoration(hintText: 'First and Last Name'),
              onChanged: (value) => setState(() => vicePresidentName = value),
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 0,
            label: 'ADA Email *',
            child: TextFormField(
              decoration: const InputDecoration(hintText: 'student@ada.edu.az'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => setState(() => vicePresidentEmail = value),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Program of Study *',
                  child: TextFormField(
                    onChanged: (value) => setState(() => vicePresidentProgram = value),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildNumberedField(
                  number: 0,
                  label: 'Graduation Year *',
                  child: TextFormField(
                    onChanged: (value) => setState(() => vicePresidentGradYear = value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 10,
            label: 'Other Core Executive Members',
            subLabel: 'List additional founding members (optional)',
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Name - Position - Email\nName - Position - Email',
              ),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNumberedField(
            number: 11,
            label: 'How does this club align with ADA University\'s mission and values? *',
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Explain how your club supports ADA\'s educational mission and core values...',
              ),
              maxLines: 4,
              onChanged: (value) => setState(() => alignment = value),
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberedField(
            number: 12,
            label: 'What is the long-term vision of the club? *',
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Describe your club\'s vision for the next 3-5 years...',
              ),
              maxLines: 4,
              onChanged: (value) => setState(() => vision = value),
            ),
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBox(
            title: 'Required Documents',
            color: Colors.blue,
            children: [
              'Please upload your club logo and constitution document to complete your application.',
            ],
          ),
          const SizedBox(height: 24),
          _buildNumberedField(
            number: 0,
            label: 'Club Logo *',
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
                    const Icon(Icons.upload, size: 48, color: AppColors.gray400),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload Club Logo',
                      style: TextStyle(fontSize: 14, color: AppColors.gray600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PNG or JPG, Min: 200x200px',
                      style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          _buildWarningBox(
            title: 'Review Before Submission',
            text: 'Please ensure all information is accurate. The Office of Student Services will contact you if any clarifications are needed.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (number > 0)
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray900,
          ),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            subLabel,
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
        ],
        const SizedBox(height: 8),
        child,
      ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          ...children.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: itemColor)),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 12, color: itemColor),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SafeArea(
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
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
                      const SnackBar(content: Text('Application submitted successfully!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_currentStep < 3 ? 'Continue >' : 'Submit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

