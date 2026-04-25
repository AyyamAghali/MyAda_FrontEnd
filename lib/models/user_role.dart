enum UserRole {
  admin('admin', 'Admin'),
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

extension UserRoleSetPermissions on Iterable<UserRole> {
  bool get isGlobalAdmin => contains(UserRole.admin);

  bool get canManageClubs =>
      isGlobalAdmin ||
      contains(UserRole.clubRep) ||
      contains(UserRole.studentServices);

  bool get canManageSupport =>
      isGlobalAdmin ||
      contains(UserRole.itAdmin) ||
      contains(UserRole.itStaff) ||
      contains(UserRole.techAdmin) ||
      contains(UserRole.techStaff) ||
      contains(UserRole.dispatcher);

  bool get canManageLostFound =>
      isGlobalAdmin ||
      contains(UserRole.lostFoundLeader) ||
      contains(UserRole.studentServices);

  bool get canManageAttendance =>
      isGlobalAdmin ||
      contains(UserRole.instructor) ||
      contains(UserRole.courseRegStaff);

  bool get canManageRooms =>
      isGlobalAdmin || contains(UserRole.studentServices);

  bool get hasAnyAdminTool =>
      canManageClubs ||
      canManageSupport ||
      canManageLostFound ||
      canManageAttendance ||
      canManageRooms;

  String get displayLabel {
    if (isEmpty) return UserRole.student.label;
    if (length == 1) return first.label;
    return map((role) => role.label).join(', ');
  }
}
