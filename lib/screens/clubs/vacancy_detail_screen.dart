import 'package:flutter/material.dart';
import '../../models/club_vacancy.dart';
import '../../utils/constants.dart';
import 'apply_vacancy_screen.dart';

class VacancyDetailScreen extends StatefulWidget {
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
  State<VacancyDetailScreen> createState() => _VacancyDetailScreenState();
}

class _VacancyDetailScreenState extends State<VacancyDetailScreen> {
  late bool _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.isSaved;
  }

  void _toggleSave() {
    setState(() => _saved = !_saved);
    widget.onSaveToggle();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vacancy;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _saved ? Icons.bookmark : Icons.bookmark_border,
                  color: _saved ? Colors.amber : AppColors.white,
                ),
                onPressed: _toggleSave,
                tooltip: _saved ? 'Unsave' : 'Save vacancy',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Employment type + location chips
                        Row(
                          children: [
                            _HeroPill(label: v.employmentType),
                            const SizedBox(width: 8),
                            _HeroPill(
                              label: v.location,
                              outlined: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          v.position,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          v.clubName,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // ── Meta strip ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                children: [
                  _MetaItem(
                    icon: Icons.access_time,
                    label: 'Posted',
                    value: v.postedAt,
                  ),
                  _divider(),
                  _MetaItem(
                    icon: Icons.group_outlined,
                    label: 'Applicants',
                    value: v.applicants,
                  ),
                  _divider(),
                  _MetaItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Deadline',
                    value: v.deadline,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // ── About section ────────────────────────────────────────
          SliverToBoxAdapter(
            child: _Section(
              title: 'About the Role',
              icon: Icons.description_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...v.aboutRole.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          p,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray700,
                            height: 1.55,
                          ),
                        ),
                      )),
                  if (v.responsibilities.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ...v.responsibilities.map((r) => _BulletRow(text: r)),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // ── Requirements ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _Section(
              title: 'Requirements',
              icon: Icons.checklist_outlined,
              child: Column(
                children: v.requirements
                    .map((r) => _CheckRow(text: r))
                    .toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // ── Benefits ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _Section(
              title: "What You'll Gain",
              icon: Icons.star_outline,
              child: Column(
                children: v.benefits
                    .map((b) => _BenefitRow(benefit: b))
                    .toList(),
              ),
            ),
          ),
          // Bottom padding for the floating button
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      // ── Apply button ─────────────────────────────────────────────
      bottomNavigationBar: _ApplyBar(
        vacancy: v,
        saved: _saved,
        onSaveToggle: _toggleSave,
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        color: AppColors.gray200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );
}

// ── Apply bottom bar ─────────────────────────────────────────────────
class _ApplyBar extends StatelessWidget {
  final ClubVacancy vacancy;
  final bool saved;
  final VoidCallback onSaveToggle;

  const _ApplyBar({
    required this.vacancy,
    required this.saved,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Save toggle button
          OutlinedButton.icon(
            onPressed: onSaveToggle,
            icon: Icon(
              saved ? Icons.bookmark : Icons.bookmark_border,
              size: 18,
              color: saved ? AppColors.secondary : AppColors.gray600,
            ),
            label: Text(
              saved ? 'Saved' : 'Save',
              style: TextStyle(
                color: saved ? AppColors.secondary : AppColors.gray600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              side: BorderSide(
                color: saved ? AppColors.secondary : AppColors.gray300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Apply button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyVacancyScreen(vacancy: vacancy),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Apply Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Reusable sub-widgets
// ════════════════════════════════════════════════════════════════════

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.gray500),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.gray400),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final bool outlined;

  const _HeroPill({required this.label, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: outlined
            ? Border.all(color: AppColors.white.withOpacity(0.6))
            : null,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  const _BulletRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;
  const _CheckRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: AppColors.secondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final VacancyBenefit benefit;
  const _BenefitRow({required this.benefit});

  static const _iconMap = <String, IconData>{
    'chart': Icons.bar_chart,
    'certificate': Icons.workspace_premium,
    'network': Icons.people_outline,
    'palette': Icons.palette_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[benefit.iconKey] ?? Icons.star_outline;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}