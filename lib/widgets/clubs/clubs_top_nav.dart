import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Which item is highlighted — mirrors MyAda_Front_Web `vacancies-nav-link--active`.
enum ClubsNavSection {
  /// No pill selected (e.g. auxiliary screens like My Memberships).
  none,
  vacancies,
  myApplications,
  events,
  clubs,
  proposeClub,
}

/// Shared top bar for club module pages (web `vacancies-nav`).
/// All taps are supplied by the parent to avoid import cycles with screen routes.
class ClubsTopNav extends StatelessWidget {
  final ClubsNavSection active;
  final VoidCallback? onLogoTap;
  final VoidCallback onVacanciesTap;
  final VoidCallback onMyApplicationsTap;
  final VoidCallback onEventsTap;
  final VoidCallback onClubsTap;
  final VoidCallback onProposeTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  const ClubsTopNav({
    super.key,
    required this.active,
    required this.onVacanciesTap,
    required this.onMyApplicationsTap,
    required this.onEventsTap,
    required this.onClubsTap,
    required this.onProposeTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: ClubNavColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: onLogoTap ??
                  () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Image.asset(
                  'assets/images/ada_logo.png',
                  height: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school,
                    size: 28,
                    color: ClubNavColors.activeText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _navPill(
                      context,
                      label: 'Vacancies',
                      section: ClubsNavSection.vacancies,
                      onTap: onVacanciesTap,
                    ),
                    _navPill(
                      context,
                      label: 'My Applications',
                      section: ClubsNavSection.myApplications,
                      onTap: onMyApplicationsTap,
                    ),
                    _navPill(
                      context,
                      label: 'Events',
                      section: ClubsNavSection.events,
                      onTap: onEventsTap,
                    ),
                    _navPill(
                      context,
                      label: 'Clubs',
                      section: ClubsNavSection.clubs,
                      onTap: onClubsTap,
                    ),
                    _navPill(
                      context,
                      label: 'Propose Club',
                      section: ClubsNavSection.proposeClub,
                      onTap: onProposeTap,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onNotificationsTap,
              icon: const Icon(Icons.notifications_outlined),
              color: ClubNavColors.link,
              tooltip: 'Notifications',
            ),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  ),
                ),
                child: const Text(
                  'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navPill(
    BuildContext context, {
    required String label,
    required ClubsNavSection section,
    required VoidCallback onTap,
  }) {
    final isActive = active == section;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? ClubNavColors.activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? ClubNavColors.activeText : ClubNavColors.link,
            ),
          ),
        ),
      ),
    );
  }
}
