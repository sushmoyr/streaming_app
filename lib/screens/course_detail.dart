import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:streaming_app/models/course.dart';
import 'package:chewie/chewie.dart';
import 'package:streaming_app/providers/current_course_provider.dart';
import 'package:streaming_app/providers/home_provider.dart';
import 'package:streaming_app/repository/course_repository.dart';
import 'package:streaming_app/utils/endpoints.dart';
import 'package:video_player/video_player.dart';

class CourseDetail extends ConsumerStatefulWidget {
  const CourseDetail({
    Key? key,
    // required this.course,
  }) : super(key: key);

  // final Course course;

  @override
  ConsumerState createState() => _CourseDetailState();
}

class _CourseDetailState extends ConsumerState<CourseDetail> {
  late final VideoPlayerController videoPlayerController;
  // await videoPlayerController.initialize();

  late final ChewieController chewieController;
  double _ratio = 16 / 9;
  late bool _isPlaying;
  bool showFeedbackMsg = true;
  late int _courseId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final course = ref.read(currentCourseProvider)!.course;
    _courseId = course.id;
    final Duration startTime = _getSavedCourseTime(course.id);
    videoPlayerController =
        VideoPlayerController.network(Endpoints.host + course.videoUrl);
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false,
        allowMuting: false,
        startAt: startTime);
    _isPlaying = chewieController.isPlaying;
    videoPlayerController.addListener(() {
      if (!_isPlaying) {
        setState(() {
          _isPlaying = true;
        });
      }
      if (videoPlayerController.value.aspectRatio != _ratio) {
        setState(() {
          _ratio = videoPlayerController.value.aspectRatio;
        });
      }
      _showFeedbackCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = ref.watch(currentCourseProvider)!.expanded
        ? MediaQuery.of(context).size.height
        : 120;
    double width = ref.watch(currentCourseProvider)!.expanded
        ? MediaQuery.of(context).size.width
        : height * _ratio;
    int? likes;
    int? dislikes;

    ref.watch(courseProvider(_courseId)).when(
          data: (course) {
            likes = course.likes;
            dislikes = course.dislikes;
          },
          error: (e, s) {},
          loading: () {},
        );

    return SizedBox(
      width: width,
      height: height,
      child: WillPopScope(
        onWillPop: () async {
          var state = ref.read(currentCourseProvider.notifier).state!;
          state = state.copyWith(expanded: !state.expanded);
          ref.read(currentCourseProvider.notifier).state = state;
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: [
              ref.watch(currentCourseProvider)!.expanded
                  ? Column(
                      children: [
                        AspectRatio(
                          aspectRatio: _ratio,
                          child: _isPlaying
                              ? Chewie(
                                  controller: chewieController,
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                ref.watch(currentCourseProvider)!.course.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Row(
                                children: [
                                  if (likes != null) ...[
                                    const Icon(
                                      Icons.thumb_up_alt_outlined,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    Text(likes!.toString()),
                                    const SizedBox(width: 16),
                                  ],
                                  if (dislikes != null) ...[
                                    const Icon(
                                      Icons.thumb_down_alt_outlined,
                                      color: Colors.redAccent,
                                      size: 16,
                                    ),
                                    Text(dislikes.toString()),
                                  ]
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: _ratio,
                          child: Chewie(
                            controller: chewieController,
                          ),
                        )
                      ],
                    ),
              if (!ref.watch(currentCourseProvider)!.expanded)
                GestureDetector(
                  onTap: () async {
                    await videoPlayerController.pause();
                    _saveCurrentTime();
                    ref.read(currentCourseProvider.notifier).state = null;
                  },
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() async {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  _saveCurrentTime() {
    final box = Hive.box('course_playback');
    Course? currentCourse = ref.read(currentCourseProvider)?.course;
    if (currentCourse != null) {
      box.put('last_played', currentCourse.toRawJson()).then((value) {
        ref.refresh(lastViewedCourseProvider);
      });
      Map<String, dynamic> data = {
        'course': currentCourse.toJson(),
        'time': videoPlayerController.value.position.inSeconds
      };
      box.put(currentCourse.id, jsonEncode(data)).then((value) {
        debugPrint(
            'Saved Course: ${currentCourse.id} at ${videoPlayerController.value.position}');
      });
    }
  }

  Duration _getSavedCourseTime(int id) {
    final box = Hive.box('course_playback');
    dynamic savedData = box.get(id);
    if (savedData != null) {
      int seconds = jsonDecode(savedData)['time'];
      debugPrint('Starts at: ${Duration(seconds: seconds)}');
      return Duration(seconds: seconds);
    }
    return Duration.zero;
  }

  void _showFeedbackCard() {
    debugPrint(videoPlayerController.value.position.toString());
    if (videoPlayerController.value.position
                .compareTo(const Duration(minutes: 1)) ==
            1 &&
        showFeedbackMsg) {
      showFeedbackMsg = false;
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Do you like this video?'),
                content: const Text(
                    'Did you like the video? If so, please hit the like button below'),
                actions: [
                  ElevatedButton.icon(
                      onPressed: () {
                        //call like api
                        ref
                            .read(courseRepositoryProvider)
                            .performAction(_courseId, CourseAction.like)
                            .then((value) {
                          ref.refresh(courseProvider(_courseId));
                          ref.refresh(homeProvider);
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text('Yes')),
                  TextButton.icon(
                      onPressed: () {
                        //call dislike api
                        ref
                            .read(courseRepositoryProvider)
                            .performAction(_courseId, CourseAction.dislike)
                            .then((value) {
                          ref.refresh(courseProvider(_courseId));
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text('No')),
                ],
              ));
    }
  }
}
