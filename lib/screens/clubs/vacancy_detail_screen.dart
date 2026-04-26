import 'package:flutter/material.dart';
import '../../models/club_vacancy.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';
import '../../utils/vacancy_category_style.dart';
import 'apply_vacancy_screen.dart';

class VacancyDetailScreen extends StatelessWidget {
  final ClubVacancy vacancy;
  final bool isSaved;
  final VoidCallback onSaveToggle;

  const VacancyDetailScreen({
    super.key,
    required this.vacancy,
    required this.isSaved,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    final v = vacancy;
    final catColor = vacancyCategoryColor(v.category);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Gradient hero header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Center(
                child: AppBackButton(onPressed: () => Navigator.pop(context)),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20, bottom: 10,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                v.categoryTag[0] + v.categoryTag.substring(1).toLowerCase(),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(v.position, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white)),
                            const SizedBox(height: 4),
                            Text(v.clubName, style: TextStyle(fontSize: 14, color: AppColors.white.withValues(alpha: 0.85))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick info strip
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                children: [
                  _metaCol(Icons.access_time, 'Posted', v.postedAt),
                  _vertDivider(),
                  _metaCol(Icons.calendar_today_outlined, 'Deadline', v.deadline),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // About the Role
          SliverToBoxAdapter(
            child: _card(
              icon: Icons.description_outlined,
              title: 'About the Role',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: v.aboutRole.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(p, style: const TextStyle(fontSize: 14, color: AppColors.gray700, height: 1.55)),
                )).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Requirements
          SliverToBoxAdapter(
            child: _card(
              icon: Icons.checklist_outlined,
              title: 'Requirements',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: v.requirements.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20, height: 20,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.check, size: 12, color: AppColors.primary),
                      ),
                      Expanded(child: Text(r, style: const TextStyle(fontSize: 14, color: AppColors.gray700, height: 1.4))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -3)),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ApplyVacancyScreen(vacancy: vacancy)));
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Apply Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _vertDivider() => Container(width: 1, height: 32, color: AppColors.gray200, margin: const EdgeInsets.symmetric(horizontal: 16));

  Widget _metaCol(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.gray500),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray700), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _card({required IconData icon, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
