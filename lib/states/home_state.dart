import '../models/course.dart';

enum Status { data, loading, error }

class HomeState {
  final List<Course> courses;
  final String? message;
  final Status status;

  const HomeState({
    required this.courses,
    this.message,
    required this.status,
  });

  factory HomeState.initial() => const HomeState(
        courses: <Course>[],
        status: Status.data,
      );

  HomeState copyWith({
    List<Course>? courses,
    String? message,
    Status? status,
  }) =>
      HomeState(
        courses: courses ?? this.courses,
        status: status ?? this.status,
        message: message ?? this.message,
      );
}
