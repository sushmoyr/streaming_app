class Endpoints {
  Endpoints._();

  static String host = 'https://shielded-fortress-71171.herokuapp.com';
  static String courses = '$host/courses';
  static String courseById(int id) => '$courses/$id';
  static String resource(String url) => '$host/$url';
}
