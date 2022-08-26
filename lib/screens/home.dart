import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaming_app/models/course.dart';
import 'package:streaming_app/providers/current_course_provider.dart';
import 'package:streaming_app/providers/home_provider.dart';
import 'package:streaming_app/screens/course_detail.dart';
import 'package:streaming_app/utils/constants.dart';
import 'package:streaming_app/utils/endpoints.dart';

import '../states/home_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          children: [
                            TextSpan(
                              text: getPeriodOfDay.characters.first,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    decorationStyle: TextDecorationStyle.double,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                            TextSpan(
                              text: getPeriodOfDay.characters.skip(1).string,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  verticalGap16,
                  //If there were any video continuing
                  _ContinueCourseSection(),
                  _CourseListSection(),
                ],
              ),
            ),
            if (ref.watch(currentCourseProvider) != null)
              const Align(
                alignment: Alignment.bottomRight,
                child: CourseDetail(),
              )
          ],
        ),
      ),
    );
  }

  String get getPeriodOfDay {
    DateTime current = DateTime.now();
    if (current.hour >= 0 && current.hour <= 11) {
      return 'Morning';
    }
    if (current.hour >= 12 && current.hour <= 13) {
      return 'Noon';
    }
    if (current.hour >= 14 && current.hour <= 17) {
      return 'Afternoon';
    }
    if (current.hour >= 18 && current.hour <= 22) {
      return 'Evening';
    }
    return 'Night';
  }
}

class _ContinueCourseSection extends ConsumerWidget {
  const _ContinueCourseSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return ref.watch(lastViewedCourseProvider).when<Widget>(
          data: (course) {
            bool hasContinueCourse = course != null;
            return hasContinueCourse
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue Watching',
                        style: textTheme.headlineMedium,
                      ),
                      CourseCard(
                        course: course,
                      ),
                      verticalGap16,
                    ],
                  )
                : Container();
          },
          error: (e, s) => Container(),
          loading: () => Container(),
        );
  }
}

class _CourseListSection extends ConsumerWidget {
  const _CourseListSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(homeProvider).status;
    final textTheme = Theme.of(context).textTheme;

    switch (status) {
      case Status.data:
        List<Course> courses = ref.watch(homeProvider).courses;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Courses',
              style: textTheme.headlineMedium,
            ),
            ListView.builder(
              itemCount: courses.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, idx) => CourseCard(
                course: courses[idx],
              ),
            )
          ],
        );
      case Status.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case Status.error:
        return Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              Text(ref.watch(homeProvider).message ?? ''),
              TextButton.icon(
                onPressed: () {
                  ref.refresh(homeProvider);
                },
                icon: Icon(Icons.refresh),
                label: Text('Refresh'),
              )
            ],
          ),
        );
    }
  }
}

class CourseCard extends ConsumerWidget {
  const CourseCard({
    Key? key,
    required this.course,
  }) : super(key: key);
  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // final route = MaterialPageRoute(builder: (ctx) => CourseDetail());
          // Navigator.push(context, route);
          ref.read(currentCourseProvider.notifier).state =
              CurrentCourseState(course: course);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Thumbnail(url: course.thumbnail),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.thumb_up_alt_outlined,
                        color: Colors.green,
                        size: 16,
                      ),
                      Text(course.likes.toString()),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.thumb_down_alt_outlined,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      Text(course.dislikes.toString()),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      Endpoints.host + url,
      loadingBuilder: (BuildContext ctx, Widget image, ImageChunkEvent? event) {
        if (event == null) {
          return image;
        }
        if (event.expectedTotalBytes == null) {
          return _loader(null);
        }

        double progress =
            event.cumulativeBytesLoaded / event.expectedTotalBytes!;
        return progress == 1 ? image : _loader(progress);
      },
    );
  }

  Widget _loader(double? value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: CircularProgressIndicator(
            value: value,
          ),
        ),
      );
}
