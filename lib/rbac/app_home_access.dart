import '../models/user_role.dart';
import '../screens/admin/support_staff_dashboard.dart';

/// Home / services visibility derived from the union of all roles for the user.
class AppHomeAccess {
  const AppHomeAccess({
    required this.showAttendanceCheck,
    required this.showLostFound,
    required this.showAdaClubs,
    required this.showSupportCenter,
    required this.showEventScanner,
    required this.showSupportDispatcherConsole,
    required this.showStaffPortal,
    required this.showLostFoundAdmin,
    required this.showClubAdminModule,
    required this.showSupportAdminModule,
    required this.showRoomAdmin,
    required this.showAttendanceAdmin,
  });

  final bool showAttendanceCheck;
  final bool showLostFound;
  final bool showAdaClubs;
  final bool showSupportCenter;
  final bool showEventScanner;
  final bool showSupportDispatcherConsole;
  final bool showStaffPortal;

  final bool showLostFoundAdmin;
  final bool showClubAdminModule;
  final bool showSupportAdminModule;
  final bool showRoomAdmin;
  final bool showAttendanceAdmin;

  static const AppHomeAccess none = AppHomeAccess(
    showAttendanceCheck: false,
    showLostFound: false,
    showAdaClubs: false,
    showSupportCenter: false,
    showEventScanner: false,
    showSupportDispatcherConsole: false,
    showStaffPortal: false,
    showLostFoundAdmin: false,
    showClubAdminModule: false,
    showSupportAdminModule: false,
    showRoomAdmin: false,
    showAttendanceAdmin: false,
  );

  static const AppHomeAccess fullAdmin = AppHomeAccess(
    showAttendanceCheck: true,
    showLostFound: true,
    showAdaClubs: true,
    showSupportCenter: true,
    showEventScanner: false,
    showSupportDispatcherConsole: true,
    showStaffPortal: true,
    showLostFoundAdmin: true,
    showClubAdminModule: false,
    showSupportAdminModule: true,
    showRoomAdmin: false,
    showAttendanceAdmin: false,
  );

  AppHomeAccess merge(AppHomeAccess o) {
    return AppHomeAccess(
      showAttendanceCheck: showAttendanceCheck || o.showAttendanceCheck,
      showLostFound: showLostFound || o.showLostFound,
      showAdaClubs: showAdaClubs || o.showAdaClubs,
      showSupportCenter: showSupportCenter || o.showSupportCenter,
      showEventScanner: showEventScanner || o.showEventScanner,
      showSupportDispatcherConsole:
          showSupportDispatcherConsole || o.showSupportDispatcherConsole,
      showStaffPortal: showStaffPortal || o.showStaffPortal,
      showLostFoundAdmin: showLostFoundAdmin || o.showLostFoundAdmin,
      showClubAdminModule: showClubAdminModule || o.showClubAdminModule,
      showSupportAdminModule: showSupportAdminModule || o.showSupportAdminModule,
      showRoomAdmin: showRoomAdmin || o.showRoomAdmin,
      showAttendanceAdmin: showAttendanceAdmin || o.showAttendanceAdmin,
    );
  }

  /// RBAC: union permissions when the user has multiple roles.
  static AppHomeAccess fromRoles(Set<UserRole> roles) {
    if (roles.contains(UserRole.admin)) return fullAdmin;

    AppHomeAccess acc = none;
    for (final role in roles) {
      acc = acc.merge(_singleRole(role));
    }
    return acc;
  }

  static AppHomeAccess _singleRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return fullAdmin;
      case UserRole.student:
        return const AppHomeAccess(
          showAttendanceCheck: true,
          showLostFound: true,
          showAdaClubs: true,
          showSupportCenter: false,
          showEventScanner: false,
          showSupportDispatcherConsole: false,
          showStaffPortal: false,
          showLostFoundAdmin: false,
          showClubAdminModule: false,
          showSupportAdminModule: false,
          showRoomAdmin: false,
          showAttendanceAdmin: false,
        );
      case UserRole.instructor:
      case UserRole.courseRegStaff:
        return const AppHomeAccess(
          showAttendanceCheck: false,
          showLostFound: true,
          showAdaClubs: true,
          showSupportCenter: true,
          showEventScanner: false,
          showSupportDispatcherConsole: false,
          showStaffPortal: false,
          showLostFoundAdmin: false,
          showClubAdminModule: false,
          showSupportAdminModule: false,
          showRoomAdmin: false,
          showAttendanceAdmin: false,
        );
      case UserRole.lostFoundLeader:
        return const AppHomeAccess(
          showAttendanceCheck: false,
          showLostFound: true,
          showAdaClubs: true,
          showSupportCenter: true,
          showEventScanner: false,
          showSupportDispatcherConsole: false,
          showStaffPortal: false,
          showLostFoundAdmin: true,
          showClubAdminModule: false,
          showSupportAdminModule: false,
          showRoomAdmin: false,
          showAttendanceAdmin: false,
        );
      case UserRole.studentServices:
        return const AppHomeAccess(
          showAttendanceCheck: false,
          showLostFound: true,
          showAdaClubs: true,
          showSupportCenter: true,
          showEventScanner: false,
          showSupportDispatcherConsole: false,
          showStaffPortal: false,
          showLostFoundAdmin: false,
          showClubAdminModule: false,
          showSupportAdminModule: false,
          showRoomAdmin: false,
          showAttendanceAdmin: false,
        );
      case UserRole.dispatcher:
        return const AppHomeAccess(
          showAttendanceCheck: false,
          showLostFound: true,
          showAdaClubs: true,
          showSupportCenter: false,
          showEventScanner: false,
          showSupportDispatcherConsole: true,
          showStaffPortal: false,
          showLostFoundAdmin: false,
          showClubAdminModule: false,
          showSupportAdminModule: false,
          showRoomAdmin: false,
          showAttendanceAdmin: false,
        );
      case UserRole.itStaff:
      case UserRole.itAdmin:
        return const AppHomeAccess(
          showAttendanceCheck: false,
          showLostFound: true,
          showAdaClubs: true,
          showSupportCenter: false,
          showEventScanner: false,
          showSupportDispatcherConsole: false,
          showStaffPortal: true,
          showLostFoundAdmin: false,
          showClubAdminModule: false,
          showSupportAdminModule: false,
          showRoomAdmin: false,
          showAttendanceAdmin: false,
        );
      case UserRole.techStaff:
      case UserRole.techAdmin:
        return const AppHomeAccess(
          showAttendanceCheck: false,
          showLostFound: true,
          showAdaClubs: true,
          showSupportCenter: false,
          showEventScanner: false,
          showSupportDispatcherConsole: false,
          showStaffPortal: true,
          showLostFoundAdmin: false,
          showClubAdminModule: false,
          showSupportAdminModule: false,
          showRoomAdmin: false,
          showAttendanceAdmin: false,
        );
      case UserRole.clubRep:
      case UserRole.clubAdmin:
        return const AppHomeAccess(
          showAttendanceCheck: false,
          showLostFound: true,
          showAdaClubs: true,
          showSupportCenter: false,
          showEventScanner: false,
          showSupportDispatcherConsole: false,
          showStaffPortal: false,
          showLostFoundAdmin: false,
          showClubAdminModule: false,
          showSupportAdminModule: false,
          showRoomAdmin: false,
          showAttendanceAdmin: false,
        );
    }
  }

  static StaffRoleType staffRoleTypeFor(Set<UserRole> roles) {
    if (roles.contains(UserRole.techStaff) ||
        roles.contains(UserRole.techAdmin)) {
      return StaffRoleType.fm;
    }
    return StaffRoleType.it;
  }
}
