class AppConfig {
  static const String apiBaseUrl =
      'fimacorserver-production.up.railway.app/MobileApiServlet';

  /// Misma app/host que MobileApiServlet, pero sin el nombre del servlet,
  /// para poder armar la URL de otros servlets del mismo contexto (por
  /// ejemplo AnalizarCarnetServlet, que ya responde JSON).
  static String get contextBaseUrl {
    final uri = Uri.parse(apiBaseUrl);
    final segments = List<String>.from(uri.pathSegments)..removeLast();
    return uri.replace(pathSegments: segments).toString();
  }

  static String get analizarCarnetUrl => '$contextBaseUrl/AnalizarCarnetServlet';
}
