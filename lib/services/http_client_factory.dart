import 'package:http/http.dart' as http;

import 'http_client_factory_web.dart'
    if (dart.library.io) 'http_client_factory_io.dart' as impl;

/// Crea el http.Client correcto para la plataforma actual:
/// - Android/iOS/desktop: cliente normal (maneja la cookie de sesion a
///   mano, ver ApiClient._headers/_saveCookies).
/// - Web: BrowserClient con withCredentials=true, para que el propio
///   navegador guarde y reenvie la cookie de sesion (en la web no se
///   puede leer ni escribir la cabecera "Cookie" desde Dart/JS, el
///   navegador la maneja el solo).
http.Client createPlatformHttpClient() => impl.createPlatformHttpClient();
