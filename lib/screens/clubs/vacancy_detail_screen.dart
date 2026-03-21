import 'package:flutter/material.dart';
import '../../data/club_vacancies_mock.dart';
import '../../models/club_vacancy.dart';
import '../../services/club_module_prefs.dart';
import '../../utils/constants.dart';
import '../../utils/vacancy_category_style.dart';
import 'apply_vacancy_screen.dart';

class VacancyDetailScreen extends StatefulWidget {
  final int vacancyId;

  const VacancyDetailScreen({super.key, required this.vacancyId});

  @override
  State<VacancyDetailScreen> createState() => _VacancyDetailScreenState();
}

class _VacancyDetailScreenState extends State<VacancyDetailScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _syncSaved();
  }

  Future<void> _syncSaved() async {
    final ids = await ClubModulePrefs.savedVacancyIds();
    if (mounted) setState(() => _saved = ids.contains(widget.vacancyId));
  }

  Future<void> _toggleSave() async {
    await ClubModulePrefs.toggleSavedVacancy(widget.vacancyId);
    await _syncSaved();
  }

  IconData _benefitIcon(String key) {
    switch (key) {
      case 'certificate':
        return Icons.verified_outlined;
      case 'network':
        return Icons.people_outline;
      case 'palette':
        return Icons.palette_outlined;
      default:
        return Icons.insights_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = getClubVacancyById(widget.vacancyId);
    if (v == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vacancy')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Vacancy not found.'),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Role details'),
            actions: [
              IconButton(
                icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border),
                onPressed: _toggleSave,
              ),
            ],
          ),
          SliverToBoxAdapter(child: _hero(context, v)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionTitle('About the Role'),
                ...v.aboutRole.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(p, style: const TextStyle(height: 1.5, color: Color(0xFF475569))),
                    )),
                const SizedBox(height: 16),
                _sectionTitle('Responsibilities'),
                ...v.responsibilities.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Color(0xFF64748B))),
                        Expanded(child: Text(r, style: const TextStyle(color: Color(0xFF475569)))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Requirements'),
                ...v.requirements.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF22C55E)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(r, style: const TextStyle(color: Color(0xFF475569)))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Benefits'),
                const SizedBox(height: 8),
                ...v.benefits.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_benefitIcon(b.iconKey), color: ClubNavColors.activeText),
                        const SizedBox(width: 10),
                        Expanded(child: Text(b.text, style: const TextStyle(color: Color(0xFF475569)))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _metaChip(Icons.event, 'Deadline: ${v.deadline}'),
                    const SizedBox(width: 8),
                    _metaChip(Icons.people_outline, v.applicants),
                  ],
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => ApplyVacancyScreen(vacancy: v)),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: ClubUiColors.ctaBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Apply now', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, ClubVacancy v) {
    final c = vacancyCategoryColor(v.category);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F2FE), Color(0xFFF8FAFC)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ClubUiColors.ctaBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(v.employmentType, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(v.location, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: c.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(vacancyCategoryIcon(v.category), color: c, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            v.position,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          Text(v.clubName, style: const TextStyle(fontSize: 16, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
    );
  }

  Widget _metaChip(IconData i, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(i, size: 18, color: ClubNavColors.activeText),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
          ],
        ),
      ),
    );
  }
}
