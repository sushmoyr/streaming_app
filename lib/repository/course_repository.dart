import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaming_app/models/course.dart';
import 'package:http/http.dart' as http;
import 'package:streaming_app/utils/endpoints.dart';

class CourseRepository {
  Future<List<Course>> fetchCourses() async {
    try {
      final response = await http.get(Uri.parse(Endpoints.courses));
      if (response.statusCode == 200) {
        List<Course> courses = List.from(jsonDecode(response.body))
            .map(
              (e) => Course.fromJson(e),
            )
            .toList();
        return courses;
      }
      return Future.error('Unknown Error Occurred');
    } on SocketException catch (e, s) {
      _log(e, s);
      return Future.error('Network Error. Check your internet connection.');
    } on TimeoutException catch (e, s) {
      _log(e, s);
      return Future.error('Request Timeout. Try Again!');
    } on Exception catch (e, s) {
      _log(e, s);
      return Future.error(e.toString());
    }
  }

  Future<Course> fetchCourseById(int id) async {
    try {
      final response = await http.get(Uri.parse(Endpoints.courseById(id)));
      if (response.statusCode == 200) {
        Course course = Course.fromRawJson(response.body);
        return course;
      }
      return Future.error('Server error');
    } on SocketException catch (e, s) {
      _log(e, s);
      return Future.error('Network Error. Check your internet connection.');
    } on TimeoutException catch (e, s) {
      _log(e, s);
      return Future.error('Request Timeout. Try Again!');
    } on Exception catch (e, s) {
      _log(e, s);
      return Future.error(e.toString());
    }
  }

  Future<Course> performAction(int id, CourseAction action) async {
    try {
      final response = await http.put(Uri.parse(action == CourseAction.like
          ? Endpoints.likeCourse(id)
          : Endpoints.dislikeCourse(id)));
      if (response.statusCode == 200) {
        Course course = Course.fromRawJson(response.body);
        return course;
      }
      return Future.error('Server error');
    } on SocketException catch (e, s) {
      _log(e, s);
      return Future.error('Network Error. Check your internet connection.');
    } on TimeoutException catch (e, s) {
      _log(e, s);
      return Future.error('Request Timeout. Try Again!');
    } on Exception catch (e, s) {
      _log(e, s);
      return Future.error(e.toString());
    }
  }

  void _log(Object? e, StackTrace? s) {
    debugPrint(e.toString());
    debugPrintStack(stackTrace: s);
  }
}

enum CourseAction { like, dislike }

final Provider<CourseRepository> courseRepositoryProvider =
    Provider((ref) => CourseRepository());
