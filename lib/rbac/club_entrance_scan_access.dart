import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/club_api_service.dart';
import '../services/club_employee_store.dart';

/// Who may use club entrance ticket scanning and for which clubs.
class ClubEntranceScanAccess {
  ClubEntranceScanAccess._();

  /// Returns `null` = show all clubs; non-null set = only those ids (may be empty).
  static Future<Set<int>?> allowedClubIdsForCurrentUser() async {
    await AuthService.instance.loadSession();
    final roles = AuthService.instance.roles;
    if (roles.contains(UserRole.admin)) return null;

    final ids = await employeeClubIds();
    return ids;
  }

  /// True if the user should see entrance-scan entry points (tickets tab, club admin tools, etc.).
  static Future<bool> canOpenEntranceScanner() async {
    await AuthService.instance.loadSession();
    final roles = AuthService.instance.roles;
    if (roles.contains(UserRole.admin)) return true;
    final ids = await employeeClubIds();
    return ids.isNotEmpty;
  }

  /// Club ids derived from staff-like memberships, local event-manager prefs, etc.
  static Future<Set<int>> employeeClubIds() async {
    final out = <int>{};
    out.addAll(await ClubEmployeeStore.eventManagerClubIds());

    final userId = AuthService.instance.studentId?.trim() ?? '';
    if (userId.isEmpty) return out;

    try {
      final api = ClubApiService();
      final raw = await api.fetchMyMemberships();
      for (final m in raw) {
        final status = (m['status'] ?? '').toString().toLowerCase();
        if (status == 'pending' ||
            status == 'applied' ||
            status == 'declined' ||
            status == 'rejected') {
          continue;
        }
        final role = (m['role'] ?? '').toString();
        if (!_membershipRoleImpliesClubStaff(role)) continue;
        final id = _parsePositiveInt(m['clubId']);
        if (id != null) out.add(id);
      }
    } catch (_) {}

    return out;
  }

  /// Plain "Member" is not club staff for scanning; any other non-empty role counts.
  static bool _membershipRoleImpliesClubStaff(String role) {
    final r = role.trim().toLowerCase();
    if (r.isEmpty || r == 'member') return false;
    return true;
  }

  static int? _parsePositiveInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value > 0 ? value : null;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    final n = int.tryParse(s);
    if (n == null || n <= 0) return null;
    return n;
  }
}
