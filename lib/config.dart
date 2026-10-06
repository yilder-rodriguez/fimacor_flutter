class AppConfig {
  /// API REST de Spring Boot desplegado en Railway.
  /// No se agrega \/login: esta URL apunta directamente al adaptador
  /// JSON que consume la app Flutter.
  static const String apiBaseUrl =
      'https://springbootfimacor-production-1fe5.up.railway.app/MobileApiServlet';
}
