class AppConfig {
  static const String apiBaseUrl =
      'https://https://fimacorserver-production-3718.up.railway.app/MobileApiServlet';

  
  static String get contextBaseUrl {
    final uri = Uri.parse(apiBaseUrl);
    final segments = List<String>.from(uri.pathSegments)..removeLast();
    return uri.replace(pathSegments: segments).toString();
  }

  static String get analizarCarnetUrl => '$contextBaseUrl/AnalizarCarnetServlet';
}
