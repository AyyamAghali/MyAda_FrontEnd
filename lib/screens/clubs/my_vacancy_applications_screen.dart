import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'club_module_nav.dart';
import 'vacancy_applications_body.dart';

/// Standalone route for vacancy applications (redirects from [ClubModuleNav] to the hub in normal flow).
class MyVacancyApplicationsScreen extends StatelessWidget {
  final String? filterClubName;

  const MyVacancyApplicationsScreen({super.key, this.filterClubName});

  @override
  Widget build(BuildContext context) {
    final scoped = filterClubName;
    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My applications',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            if (scoped != null)
              Text(
                scoped,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.gray200, height: 1),
        ),
      ),
      body: VacancyApplicationsBody(
        filterClubName: filterClubName,
        showBrowseVacanciesAction: true,
        onBrowseOpenings: () => ClubModuleNav.openVacancies(
          context,
          clubName: scoped,
        ),
      ),
    );
  }
}
