import 'package:flutter/material.dart';
import '../../models/club_vacancy.dart';
import '../../services/club_api_service.dart';
import '../../utils/constants.dart';
import '../../utils/vacancy_category_style.dart';
import 'apply_vacancy_screen.dart';

/// Apply-by highlight (deadline urgency) — amber from previous deadline card.
const Color _kApplyByBorder = Color(0xFFF59E0B);
const Color _kApplyByLabel = Color(0xFFB45309);

/// Brand hero + CTA: vibrant blue → app primary → app red/rose secondary.
const LinearGradient _kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    ClubUiColors.ctaBlue,
    AppColors.primary,
    AppColors.secondary,
  ],
  stops: [0.0, 0.48, 1.0],
);

const LinearGradient _kApplyByFill = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFFFBEB),
    Color(0xFFFEF3C7),
  ],
);

const Color _kIconBlue = Color(0xFF2563EB);
const Color _kIconBlueBg = Color(0xFFDBEAFE);
const Color _kCheckCircleBg = Color(0xFFD1FAE5);
const Color _kCheckIcon = Color(0xFF047857);

class _StaticGain {
  final IconData icon;
  final String text;
  const _StaticGain(this.icon, this.text);
}

/// Shown on every vacancy detail (not from API).
const List<_StaticGain> _kWhatYoullGainItems = [
  _StaticGain(Icons.bar_chart_rounded, 'Hands-on experience'),
  _StaticGain(Icons.link_rounded, 'Certificate of contribution'),
  _StaticGain(Icons.people_outline_rounded, 'Networking opportunities'),
  _StaticGain(Icons.auto_awesome_rounded, 'Creative freedom'),
];

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
  late ClubVacancy _vacancy;
  final ClubApiService _api = ClubApiService();
  bool _loading = true;
  String? _error;
  late List<String> _requirementLines;

  @override
  void initState() {
    super.initState();
    _vacancy = widget.vacancy;
    _requirementLines = List<String>.from(widget.vacancy.requirements);
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final v = await _api.fetchVacancyById(widget.vacancy.id);
      var reqs = List<String>.from(v.requirements);
      if (reqs.isEmpty && v.clubPositionId != null && v.clubPositionId! > 0) {
        try {
          reqs =
              await _api.fetchClubPositionRequirementTexts(v.clubPositionId!);
        } catch (_) {
          // Position requirements are optional; keep empty.
        }
      }
      if (!mounted) return;
      setState(() {
        _vacancy = v;
        _requirementLines = reqs;
        _loading = false;
        _error = null;
      });
    } on ClubApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load vacancy details.';
      });
    }
  }

  bool get _canApply => _vacancy.isActive && !_vacancy.isDraft;

  String? get _statusChipLabel {
    if (_vacancy.isDraft) return 'Draft';
    if (!_vacancy.isActive) return 'Closed';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final v = _vacancy;
    final topInset = MediaQuery.paddingOf(context).top;
    final w = MediaQuery.sizeOf(context).width;
    final twoCol = w >= 720;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (_loading)
              SliverToBoxAdapter(
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: AppColors.secondary,
                  backgroundColor: AppColors.gray200,
                ),
              ),
            if (_error != null) SliverToBoxAdapter(child: _errorBanner()),
            SliverToBoxAdapter(
              child: _heroWithCard(
                context: context,
                v: v,
                topInset: topInset,
              ),
            ),
            if (!twoCol) SliverToBoxAdapter(child: _postedDeadlineStrip(v)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  twoCol ? 8 : 10,
                  16,
                  16 + MediaQuery.paddingOf(context).bottom,
                ),
                child: twoCol
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 65,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _compactMetaInline(v),
                                const SizedBox(height: 16),
                                _surfaceCard(child: _aboutSection(v)),
                                const SizedBox(height: 16),
                                _surfaceCard(child: _whatYoullGainSection()),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 35,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _surfaceCard(child: _requirementsSection()),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _surfaceCard(child: _aboutSection(v)),
                          const SizedBox(height: 20),
                          _surfaceCard(child: _whatYoullGainSection()),
                          const SizedBox(height: 20),
                          _surfaceCard(child: _requirementsSection()),
                        ],
                      ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 72)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: _gradientApplyButton(context),
          ),
        ),
      ),
    );
  }

  Widget _gradientApplyButton(BuildContext context) {
    if (!_canApply) {
      return SizedBox(
        height: 50,
        width: double.infinity,
        child: FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gray200,
            foregroundColor: AppColors.gray500,
            disabledBackgroundColor: AppColors.gray200,
            disabledForegroundColor: AppColors.gray500,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_rounded, size: 20),
              SizedBox(width: 10),
              Text(
                'Applications closed',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ApplyVacancyScreen(vacancy: _vacancy),
              ),
            );
          },
          child: Ink(
            decoration: const BoxDecoration(
              gradient: _kBrandGradient,
            ),
            child: const SizedBox(
              height: 50,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_rounded, color: AppColors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Apply Now',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorBanner() {
    return Material(
      color: const Color(0xFFFEF3C7),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFB45309), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _error!,
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                ),
              ),
              TextButton(
                onPressed: _loadDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroWithCard({
    required BuildContext context,
    required ClubVacancy v,
    required double topInset,
  }) {
    const heroHeight = 132.0;
    const cardOverlap = 40.0;
    final chip = _statusChipLabel;
    final catColor = vacancyCategoryColor(v.category);
    final catIcon = vacancyCategoryIcon(v.category);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: heroHeight + topInset,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: _kBrandGradient,
                  ),
                ),
              ),
              Positioned(
                right: -24,
                top: topInset - 10,
                child: Icon(
                  Icons.circle,
                  size: 100,
                  color: AppColors.white.withValues(alpha: 0.06),
                ),
              ),
              Positioned(
                left: -16,
                top: topInset + 28,
                child: Icon(
                  Icons.circle,
                  size: 64,
                  color: AppColors.white.withValues(alpha: 0.05),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8, top: topInset),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppColors.white.withValues(alpha: 0.15),
                            foregroundColor: AppColors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -cardOverlap),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        catIcon,
                        color: catColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (chip != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          chip,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      v.position,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      v.clubName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  /// Mobile-only: two-column date strip under hero.
  Widget _postedDeadlineStrip(ClubVacancy v) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _stripItem(Icons.schedule_rounded, 'Posted', v.postedAt),
            ),
            Container(width: 1, height: 56, color: AppColors.gray200),
            Expanded(
              child: _stripApplyByItem(v.deadline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stripApplyByItem(String deadlineText) {
    final display = deadlineText.trim().isEmpty ? '—' : deadlineText;
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 2),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        gradient: _kApplyByFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kApplyByBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kApplyByBorder.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.alarm_rounded, size: 22, color: _kApplyByLabel),
          const SizedBox(height: 6),
          const Text(
            'Apply by',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _kApplyByLabel,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            display,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stripItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 22, color: _kIconBlue),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  /// Desktop / tablet: single compact line (avoids duplicating full strip).
  Widget _compactMetaInline(ClubVacancy v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.schedule_rounded, size: 22, color: _kIconBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Posted',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        v.postedAt,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              gradient: _kApplyByFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kApplyByBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _kApplyByBorder.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.alarm_rounded, size: 22, color: _kApplyByLabel),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apply by',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _kApplyByLabel,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        v.deadline,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _surfaceCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _kIconBlueBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: _kIconBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
        ),
      ],
    );
  }

  List<String> _meaningfulAboutParagraphs(ClubVacancy v) {
    return v.aboutRole
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty && p != '—' && p != '-' && p != '–')
        .toList();
  }

  Widget _aboutSection(ClubVacancy v) {
    final paragraphs = _meaningfulAboutParagraphs(v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
            icon: Icons.description_outlined, title: 'About the Role'),
        const SizedBox(height: 12),
        if (paragraphs.isEmpty)
          Text(
            'No description was provided for this vacancy.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500.withValues(alpha: 0.95),
              height: 1.55,
            ),
          )
        else
          ...paragraphs.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                p,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.55,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _whatYoullGainSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
            icon: Icons.workspace_premium_outlined, title: "What You'll Gain"),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, c) {
            final tileW = (c.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _kWhatYoullGainItems.map((g) {
                return SizedBox(
                  width: tileW.clamp(120.0, 280.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _kIconBlueBg,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(g.icon, color: _kIconBlue, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            g.text,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _requirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(icon: Icons.fact_check_outlined, title: 'Requirements'),
        const SizedBox(height: 14),
        if (_requirementLines.isEmpty)
          Text(
            'No specific requirements were listed. Reach out to the club if you have questions.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500.withValues(alpha: 0.95),
              height: 1.55,
            ),
          )
        else
          ..._requirementLines.map(_requirementRow),
      ],
    );
  }

  Widget _requirementRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 21,
            height: 21,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration: const BoxDecoration(
              color: _kCheckCircleBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 13,
              color: _kCheckIcon,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
