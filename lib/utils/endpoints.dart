class Endpoints {
  Endpoints._();

  static String host = '';
  static String courses = '$host/courses';
  static String courseById(int id) => '$courses/$id';
  static String resource(String url) => '$host/$url';
}
