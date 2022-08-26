import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:streaming_app/models/course.dart';
import 'package:streaming_app/repository/course_repository.dart';

class CurrentCourseState {
  final Course course;
  final bool expanded;

  CurrentCourseState({
    required this.course,
    this.expanded = true,
  });

  CurrentCourseState copyWith({
    Course? course,
    bool? expanded,
  }) =>
      CurrentCourseState(
          course: course ?? this.course, expanded: expanded ?? this.expanded);
}

final currentCourseProvider = StateProvider<CurrentCourseState?>((ref) => null);

final courseProvider = FutureProvider.family<Course, int>((ref, id) async {
  return ref.watch(courseRepositoryProvider).fetchCourseById(id);
});

final lastViewedCourseProvider = FutureProvider<Course?>((ref) async {
  final db = Hive.box('course_playback');
  String? lastPlayedRaw = db.get('last_played');
  if (lastPlayedRaw != null) {
    Course course = Course.fromRawJson(lastPlayedRaw);
    return ref.read(courseRepositoryProvider).fetchCourseById(course.id);
  }
  return null;
});
