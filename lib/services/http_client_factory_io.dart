import 'package:http/http.dart' as http;

/// En Android/iOS/desktop no hay restriccion del navegador: seguimos
/// manejando la cookie de sesion a mano (ver ApiClient._headers).
http.Client createPlatformHttpClient() => http.Client();
