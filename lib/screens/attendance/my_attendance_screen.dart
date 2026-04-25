import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  final _service = AttendanceService();
  final Map<int, _LessonIdentity> _lessonIdentityCache = {};
  bool _loading = true;
  String? _error;
  List<_EnrolledLesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final studentId = AuthService.instance.studentId;
      if (studentId == null || studentId.isEmpty) {
        throw const AttendanceServiceException(
            message: 'Not signed in. Please log in again.');
      }

      final raw = await _service.fetchStudentEnrollments(studentId: studentId);
      final lessons = await _resolveMissingLessonNames(_parseEnrollments(raw));
      if (mounted) {
        setState(() {
          _lessons = lessons;
          _loading = false;
        });
      }
    } on AttendanceServiceException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load attendance data.';
          _loading = false;
        });
      }
    }
  }

  List<_EnrolledLesson> _parseEnrollments(Object? raw) {
    if (raw == null) return [];
    List<dynamic> list;

    if (raw is List) {
      list = raw;
    } else if (raw is Map<String, dynamic>) {
      final result = raw['result'] ?? raw['data'] ?? raw['enrollments'];
      if (result is List) {
        list = result;
      } else {
        return [];
      }
    } else {
      return [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => _EnrolledLesson.fromJson(e))
        .toList();
  }

  Future<List<_EnrolledLesson>> _resolveMissingLessonNames(
    List<_EnrolledLesson> lessons,
  ) async {
    final resolved = <_EnrolledLesson>[];

    for (final lesson in lessons) {
      if (!lesson.needsNameLookup || lesson.lessonId <= 0) {
        resolved.add(lesson);
        continue;
      }

      final identity = await _fetchLessonIdentity(lesson.lessonId);
      resolved.add(
        lesson.copyWith(
          courseName: identity?.name,
          courseCode: lesson.courseCode ?? identity?.code,
          instructor: lesson.instructor ?? identity?.instructor,
        ),
      );
    }

    return resolved;
  }

  Future<_LessonIdentity?> _fetchLessonIdentity(int lessonId) async {
    if (_lessonIdentityCache.containsKey(lessonId)) {
      return _lessonIdentityCache[lessonId];
    }

    try {
      final raw = await _service.fetchLessonById(lessonId: lessonId);
      final identity = _LessonIdentity.fromRaw(raw);
      if (identity != null) _lessonIdentityCache[lessonId] = identity;
      return identity;
    } catch (_) {
      // Course stats are still useful even if the lookup endpoint is unavailable.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppColors.gray700),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Attendance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Enrolled courses & records',
                style: TextStyle(fontSize: 13, color: AppColors.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_lessons.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadEnrollments,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: _lessons.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _LessonCard(
          lesson: _lessons[i],
          onTap: () => _openLessonDetail(_lessons[i]),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.gray500),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _loadEnrollments,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 60, color: AppColors.gray300),
          const SizedBox(height: 16),
          const Text(
            'No enrolled courses',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your enrolled courses and attendance\nrecords will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.gray400),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _loadEnrollments,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _openLessonDetail(_EnrolledLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LessonAttendanceDetail(lesson: lesson),
      ),
    );
  }
}

// ── Models ─────────────────────────────────────────────────────────────────────

class _EnrolledLesson {
  static const String unknownCourseName = 'Unknown Course';

  final int lessonId;
  final String courseName;
  final String? courseCode;
  final String? instructor;
  final int totalSessions;
  final int present;
  final int late;
  final int absent;
  final int excused;

  const _EnrolledLesson({
    required this.lessonId,
    required this.courseName,
    this.courseCode,
    this.instructor,
    this.totalSessions = 0,
    this.present = 0,
    this.late = 0,
    this.absent = 0,
    this.excused = 0,
  });

  double get attendanceRate {
    final attended = present + late + excused;
    return totalSessions > 0 ? attended / totalSessions : 0;
  }

  bool get needsNameLookup =>
      courseName.trim().isEmpty || courseName == unknownCourseName;

  _EnrolledLesson copyWith({
    String? courseName,
    String? courseCode,
    String? instructor,
  }) {
    return _EnrolledLesson(
      lessonId: lessonId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      instructor: instructor ?? this.instructor,
      totalSessions: totalSessions,
      present: present,
      late: late,
      absent: absent,
      excused: excused,
    );
  }

  factory _EnrolledLesson.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    String? text(dynamic value) {
      final str = value?.toString().trim();
      return str == null || str.isEmpty ? null : str;
    }

    final lesson = json['lesson'] is Map<String, dynamic>
        ? json['lesson'] as Map<String, dynamic>
        : null;
    final rawCourse = json['course'] ?? lesson?['course'];
    final course = rawCourse is Map<String, dynamic> ? rawCourse : null;
    final lessonName = text(course?['name']) ??
        text(json['courseName']) ??
        text(lesson?['courseName']) ??
        text(json['name']) ??
        text(lesson?['name']) ??
        unknownCourseName;

    return _EnrolledLesson(
      lessonId: asInt(json['lessonId'] ??
          lesson?['lessonId'] ??
          lesson?['id'] ??
          json['id']),
      courseName: lessonName,
      courseCode: text(course?['code']) ??
          text(json['courseCode']) ??
          text(lesson?['courseCode']),
      instructor: text(json['instructorName']) ??
          text(lesson?['instructorName']) ??
          text(json['instructor']),
      totalSessions: asInt(json['totalSessions']),
      present: asInt(json['presentCount'] ?? json['present']),
      late: asInt(json['lateCount'] ?? json['late']),
      absent: asInt(json['absentCount'] ?? json['absent']),
      excused: asInt(json['excusedCount'] ?? json['excused']),
    );
  }
}

class _LessonIdentity {
  final String name;
  final String? code;
  final String? instructor;

  const _LessonIdentity({
    required this.name,
    this.code,
    this.instructor,
  });

  static _LessonIdentity? fromRaw(Object? raw) {
    final map = _asMap(raw);
    if (map == null) return null;

    String? text(dynamic value) {
      final str = value?.toString().trim();
      return str == null || str.isEmpty ? null : str;
    }

    final course = map['course'] is Map<String, dynamic>
        ? map['course'] as Map<String, dynamic>
        : null;
    final name =
        text(course?['name']) ?? text(map['courseName']) ?? text(map['name']);

    if (name == null) return null;

    return _LessonIdentity(
      name: name,
      code: text(course?['code']) ?? text(map['courseCode']),
      instructor: text(map['instructorName']) ?? text(map['instructor']),
    );
  }

  static Map<String, dynamic>? _asMap(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final result = raw['result'];
      if (result is Map<String, dynamic>) return result;
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return null;
  }
}

// ── Lesson Card Widget ─────────────────────────────────────────────────────────

class _LessonCard extends StatelessWidget {
  final _EnrolledLesson lesson;
  final VoidCallback onTap;

  const _LessonCard({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rate = lesson.attendanceRate;
    final rateColor = rate >= 0.8
        ? const Color(0xFF16A34A)
        : rate >= 0.6
            ? const Color(0xFFF59E0B)
            : const Color(0xFFDC2626);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      size: 22, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.courseName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (lesson.courseCode != null)
                        Text(
                          lesson.courseCode!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.gray500),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rateColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(rate * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: rateColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.gray400),
              ],
            ),
            const SizedBox(height: 14),
            // Stat row
            Row(
              children: [
                _StatChip(
                    label: 'Present',
                    count: lesson.present,
                    color: const Color(0xFF16A34A)),
                const SizedBox(width: 8),
                _StatChip(
                    label: 'Late',
                    count: lesson.late,
                    color: const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _StatChip(
                    label: 'Absent',
                    count: lesson.absent,
                    color: const Color(0xFFDC2626)),
                const SizedBox(width: 8),
                _StatChip(
                    label: 'Excused',
                    count: lesson.excused,
                    color: const Color(0xFF6366F1)),
              ],
            ),
            if (lesson.totalSessions > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: rate,
                  minHeight: 6,
                  backgroundColor: AppColors.gray100,
                  valueColor: AlwaysStoppedAnimation<Color>(rateColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${lesson.present + lesson.late + lesson.excused} of ${lesson.totalSessions} sessions attended',
                style: const TextStyle(fontSize: 12, color: AppColors.gray400),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lesson Attendance Detail Screen ────────────────────────────────────────────

class _LessonAttendanceDetail extends StatefulWidget {
  final _EnrolledLesson lesson;

  const _LessonAttendanceDetail({required this.lesson});

  @override
  State<_LessonAttendanceDetail> createState() =>
      _LessonAttendanceDetailState();
}

class _LessonAttendanceDetailState extends State<_LessonAttendanceDetail> {
  final _service = AttendanceService();
  bool _loading = true;
  String? _error;
  List<_SessionRecord> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final studentId = AuthService.instance.studentId;
      if (studentId == null || studentId.isEmpty) {
        throw const AttendanceServiceException(message: 'Not signed in.');
      }

      final raw = await _service.fetchStudentLessonAttendance(
        studentId: studentId,
        lessonId: widget.lesson.lessonId,
      );

      final sessions = _parseSessions(raw);
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _loading = false;
        });
      }
    } on AttendanceServiceException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load session data.';
          _loading = false;
        });
      }
    }
  }

  List<_SessionRecord> _parseSessions(Object? raw) {
    if (raw == null) return [];
    List<dynamic> list;

    if (raw is List) {
      list = raw;
    } else if (raw is Map<String, dynamic>) {
      final result = raw['result'] ?? raw['data'] ?? raw['attendance'];
      if (result is List) {
        list = result;
      } else {
        return [];
      }
    } else {
      return [];
    }

    final sessions = list
        .whereType<Map<String, dynamic>>()
        .map((e) => _SessionRecord.fromJson(e))
        .toList();

    sessions.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildSummaryBar(),
            Expanded(child: _buildSessionList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppColors.gray700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson.courseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.lesson.courseCode != null)
                  Text(
                    widget.lesson.courseCode!,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.gray500),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    final lesson = widget.lesson;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF3D7A96)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
              label: 'Present', value: lesson.present.toString(), light: true),
          _SummaryItem(
              label: 'Late', value: lesson.late.toString(), light: true),
          _SummaryItem(
              label: 'Absent', value: lesson.absent.toString(), light: true),
          _SummaryItem(
              label: 'Rate',
              value: '${(lesson.attendanceRate * 100).toInt()}%',
              light: true),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.gray300),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.gray500)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadSessions,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            const Text('No session records yet',
                style: TextStyle(fontSize: 15, color: AppColors.gray500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSessions,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: _sessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _SessionTile(session: _sessions[i]),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool light;

  const _SummaryItem(
      {required this.label, required this.value, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: light ? Colors.white : AppColors.gray900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: light ? Colors.white.withOpacity(0.75) : AppColors.gray500,
          ),
        ),
      ],
    );
  }
}

class _SessionRecord {
  final int? sessionId;
  final DateTime? date;
  final String? startTime;
  final String? topic;
  final String status;
  final String? note;

  const _SessionRecord({
    this.sessionId,
    this.date,
    this.startTime,
    this.topic,
    required this.status,
    this.note,
  });

  factory _SessionRecord.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    Map<String, dynamic>? asMap(dynamic value) {
      return value is Map<String, dynamic> ? value : null;
    }

    String? text(dynamic value) {
      final str = value?.toString().trim();
      return str == null || str.isEmpty ? null : str;
    }

    String? firstText(List<dynamic> values) {
      for (final value in values) {
        final str = text(value);
        if (str != null) return str;
      }
      return null;
    }

    DateTime? parseSessionDateTime(String? rawDate, String? rawStartTime) {
      final parsedStartTime =
          rawStartTime != null ? DateTime.tryParse(rawStartTime) : null;
      if (parsedStartTime != null) return parsedStartTime;

      if (rawDate == null) return null;

      if (rawStartTime != null) {
        final datePart = rawDate.split('T').first.split(' ').first;
        final timePart = rawStartTime.split('.').first;
        return DateTime.tryParse('${datePart}T$timePart') ??
            DateTime.tryParse('$datePart $timePart');
      }

      return DateTime.tryParse(rawDate);
    }

    final session = asMap(json['session']);
    final lessonSession = asMap(json['lessonSession']);
    final rawDate = firstText([
      json['sessionDate'],
      json['date'],
      json['lessonDate'],
      json['startDate'],
      json['scheduledDate'],
      json['createdAt'],
      session?['sessionDate'],
      session?['date'],
      session?['lessonDate'],
      session?['startDate'],
      session?['scheduledDate'],
      lessonSession?['sessionDate'],
      lessonSession?['date'],
      lessonSession?['startDate'],
    ]);
    final rawStartTime = firstText([
      json['startTime'],
      json['sessionStartTime'],
      json['time'],
      session?['startTime'],
      session?['sessionStartTime'],
      session?['time'],
      lessonSession?['startTime'],
      lessonSession?['sessionStartTime'],
    ]);

    return _SessionRecord(
      sessionId: asInt(json['sessionId'] ?? session?['id'] ?? json['id']),
      date: parseSessionDateTime(rawDate, rawStartTime),
      startTime: rawStartTime,
      topic: _normalizeSessionTopic(
          text(json['topic']) ?? text(session?['topic'])),
      status: json['status']?.toString() ?? 'Unknown',
      note: json['instructorNote']?.toString() ?? json['note']?.toString(),
    );
  }

  static String? _normalizeSessionTopic(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    if (normalized == 'no date' ||
        normalized == 'n/a' ||
        normalized == 'null' ||
        normalized == '-') {
      return null;
    }
    return value;
  }
}

class _SessionTile extends StatelessWidget {
  final _SessionRecord session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final statusLower = session.status.toLowerCase();
    final Color statusColor;
    final IconData statusIcon;

    switch (statusLower) {
      case 'present':
        statusColor = const Color(0xFF16A34A);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'late':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.access_time_rounded;
        break;
      case 'absent':
        statusColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_rounded;
        break;
      case 'excused':
        statusColor = const Color(0xFF6366F1);
        statusIcon = Icons.verified_rounded;
        break;
      default:
        statusColor = AppColors.gray400;
        statusIcon = Icons.help_outline_rounded;
    }

    final dateStr = session.date != null
        ? DateFormat('EEE, MMM d, yyyy').format(session.date!)
        : 'Date unavailable';
    final timeStr = session.date != null
        ? DateFormat('h:mm a').format(session.date!)
        : session.startTime ?? '';
    final hasTopic = session.topic != null && session.topic!.trim().isNotEmpty;
    final title = hasTopic ? session.topic! : dateStr;
    final subtitle = hasTopic
        ? [dateStr, timeStr].where((part) => part.isNotEmpty).join(' • ')
        : timeStr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, size: 20, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.gray400),
                  )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              session.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
