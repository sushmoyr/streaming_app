import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:streaming_app/models/course.dart';
import 'package:chewie/chewie.dart';
import 'package:streaming_app/providers/current_course_provider.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final course = ref.watch(currentCourseProvider)!.course;
    videoPlayerController =
        VideoPlayerController.network(Endpoints.host + course.videoUrl);
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: false,
      allowMuting: false,
    );
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
                                  const Icon(
                                    Icons.thumb_up_alt_outlined,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  Text(ref
                                      .watch(currentCourseProvider)!
                                      .course
                                      .likes
                                      .toString()),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.thumb_down_alt_outlined,
                                    color: Colors.redAccent,
                                    size: 16,
                                  ),
                                  Text(ref
                                      .watch(currentCourseProvider)!
                                      .course
                                      .dislikes
                                      .toString()),
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
                  onTap: () {
                    ref.read(currentCourseProvider.notifier).state = null;
                  },
                  child: Icon(
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
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }
}
