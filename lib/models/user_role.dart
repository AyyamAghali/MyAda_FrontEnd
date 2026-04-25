enum UserRole {
  admin('admin', 'Admin'),
  /// Club officer / employee (Ada Clubs + event scanner scope).
  clubAdmin('club_admin', 'Club admin'),
  clubRep('club_rep', 'Club representative'),
  courseRegStaff('course_reg_staff', 'Course registration staff'),
  dispatcher('dispatcher', 'Dispatcher'),
  instructor('instructor', 'Instructor'),
  itAdmin('it_admin', 'IT admin'),
  itStaff('it_staff', 'IT staff'),
  lostFoundLeader('lost_found_leader', 'Lost & Found leader'),
  student('student', 'Student'),
  studentServices('student_services', 'Student services'),
  techAdmin('tech_admin', 'Tech admin'),
  techStaff('tech_staff', 'Tech staff');

  const UserRole(this.apiName, this.label);

  final String apiName;
  final String label;

  static UserRole? fromApiName(Object? value) {
    final normalized = value
        ?.toString()
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    if (normalized == null || normalized.isEmpty) return null;

    for (final role in values) {
      if (role.apiName == normalized ||
          role.name.toLowerCase() == normalized ||
          role.apiName.toUpperCase() == normalized.toUpperCase()) {
        return role;
      }
    }
    return null;
  }
}

extension UserRoleSetDisplay on Iterable<UserRole> {
  String get displayLabel {
    if (isEmpty) return UserRole.student.label;
    if (length == 1) return first.label;
    return map((role) => role.label).join(', ');
  }
}
