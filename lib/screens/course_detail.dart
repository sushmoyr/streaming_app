import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:streaming_app/models/course.dart';
import 'package:chewie/chewie.dart';
import 'package:streaming_app/utils/endpoints.dart';
import 'package:video_player/video_player.dart';

class CourseDetail extends ConsumerStatefulWidget {
  const CourseDetail({
    Key? key,
    required this.course,
  }) : super(key: key);

  final Course course;

  @override
  ConsumerState createState() => _CourseDetailState();
}

class _CourseDetailState extends ConsumerState<CourseDetail> {
  late final VideoPlayerController videoPlayerController;
  // await videoPlayerController.initialize();

  late final ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController =
        VideoPlayerController.network(Endpoints.host + widget.course.videoUrl);
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chewie(
        controller: chewieController,
      ),
    );
  }
}
