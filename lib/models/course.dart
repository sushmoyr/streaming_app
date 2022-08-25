import 'dart:convert';

class Course {
  final int id;
  final String title;
  final String videoUrl;
  final String thumbnail;
  final int likes;
  final int dislikes;

  const Course({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnail,
    required this.likes,
    required this.dislikes,
  });

  factory Course.fromRawJson(String raw) {
    return Course.fromJson(jsonDecode(raw));
  }

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'],
        title: json['title'],
        videoUrl: json['videoUrl'],
        thumbnail: json['thumbnail'],
        likes: json['likes'],
        dislikes: json['dislikes'],
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnail': thumbnail,
      'likes': likes,
      'dislikes': dislikes,
    };
  }

  String toRawJson() => jsonEncode(toJson());
}
