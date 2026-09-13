import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// En Flutter Web, Dart/JS no puede leer ni escribir la cabecera
/// "Cookie" (el navegador la bloquea por seguridad: intentarlo hace que
/// fetch() falle con "Failed to fetch", sin ni siquiera llegar al
/// servidor). withCredentials=true le pide al navegador que el SI
/// adjunte y guarde la cookie de sesion automaticamente, siempre que el
/// servidor responda con Access-Control-Allow-Credentials: true y un
/// origen exacto (no "*"), que es justo como esta configurado
/// MobileApiServlet.
http.Client createPlatformHttpClient() => BrowserClient()..withCredentials = true;
