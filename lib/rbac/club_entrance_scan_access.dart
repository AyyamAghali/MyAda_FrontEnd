import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/club_api_service.dart';

/// Who may use club entrance ticket scanning and for which clubs.
class ClubEntranceScanAccess {
  ClubEntranceScanAccess._();

  /// Returns `null` = show all clubs; non-null set = only those ids (may be empty).
  static Future<Set<int>?> allowedClubIdsForCurrentUser() async {
    await AuthService.instance.loadSession();
    final roles = AuthService.instance.roles;
    if (roles.contains(UserRole.admin)) return null;
    if (roles.contains(UserRole.clubAdmin) || roles.contains(UserRole.clubRep)) {
      return null;
    }

    final ids = await staffClubIdsFromMemberships();
    return ids;
  }

  /// True if the user should see entrance-scan entry points (tickets tab, club admin tools, etc.).
  static Future<bool> canOpenEntranceScanner() async {
    await AuthService.instance.loadSession();
    final roles = AuthService.instance.roles;
    if (roles.contains(UserRole.admin)) return true;
    if (roles.contains(UserRole.clubAdmin) || roles.contains(UserRole.clubRep)) {
      return true;
    }
    final ids = await staffClubIdsFromMemberships();
    return ids.isNotEmpty;
  }

  /// Club ids where the user's **membership role** is club staff (officers/managers), not plain members.
  static Future<Set<int>> staffClubIdsFromMemberships() async {
    final out = <int>{};
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

  /// True when the per-club membership role is leadership/operations (can scan), not a generic member.
  static bool _membershipRoleImpliesClubStaff(String role) {
    final r = role.trim().toLowerCase();
    if (r.isEmpty) return false;

    // Reject common member-only labels (and phrases that are still "just a member").
    const memberOnlyExact = {
      'member',
      'members',
      'club member',
      'active member',
      'general member',
      'regular member',
      'student member',
      'standard member',
    };
    if (memberOnlyExact.contains(r)) return false;

    // Leadership / ops titles — must match at least one hint (avoids "Participant", random strings, etc.).
    final staffHints = RegExp(
      r'president|vice|treasurer|secretary|officer|manager|managing|'
      r'admin|administrator|director|coordinator|captain|chair|head|'
      r'founder|exec|board|committee|representative|ambassador|'
      r'steward|planner|organizer|team\s*lead|\blead\b|\bstaff\b',
      caseSensitive: false,
    );
    return staffHints.hasMatch(r);
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
