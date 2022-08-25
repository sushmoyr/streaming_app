import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaming_app/models/course.dart';
import 'package:streaming_app/repository/course_repository.dart';
import 'package:streaming_app/states/home_state.dart';

final homeProvider = StateNotifierProvider<HomeStateNotifier, HomeState>(
  (ref) => HomeStateNotifier(ref.read(courseRepositoryProvider)),
);

class HomeStateNotifier extends StateNotifier<HomeState> {
  HomeStateNotifier(this._repository) : super(HomeState.initial()) {
    fetchVideos();
  }

  final CourseRepository _repository;

  void fetchVideos() async {
    state = state.copyWith(status: Status.loading);
    _repository.fetchCourses().then((courses) {
      state = state.copyWith(courses: courses, status: Status.data);
    }).catchError((e) {
      state = state.copyWith(status: Status.error, message: e.toString());
    });
  }
}
