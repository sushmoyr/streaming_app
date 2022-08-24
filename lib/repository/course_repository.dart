import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaming_app/models/course.dart';

class VideoRepository {
  Future<List<Course>> fetchCourses() {}
}

final Provider<VideoRepository> videoRepositoryProvider =
    Provider((ref) => VideoRepository());
