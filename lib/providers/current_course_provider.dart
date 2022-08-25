import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaming_app/models/course.dart';

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
