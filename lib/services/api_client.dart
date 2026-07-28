import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/api_exception.dart';
import '../models/dashboard_summary.dart';
import '../models/login_result.dart';
import '../models/machine.dart';
import '../models/maintenance_item.dart';
import '../models/manual_item.dart';
import '../models/repair_pending.dart';
import '../models/json_helpers.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static final Uri baseUri = Uri.parse(AppConfig.apiBaseUrl);

  final http.Client _client;
  final Map<String, String> _cookies = {};
  int? _userId;
  String? _role;

  /// Roles autorizados a usar esta app movil. Se compara en minuscula y
  /// solo requiere que el texto CONTENGA una de estas palabras, para
  /// tolerar variantes como "Cuentadante" o "Tecnico de mantenimiento".
  static const _rolesPermitidos = ['cuentadante', 'tecnico'];

  String get cookieHeader =>
      _cookies.entries.map((entry) => '${entry.key}=${entry.value}').join('; ');

  /// Rol de la sesion activa ("Cuentadante", "Tecnico", etc.), o null si
  /// no hay sesion iniciada.
  String? get role => _role;

  bool get isTecnico => (_role ?? '').toLowerCase().contains('tecnico');

  Future<LoginResult> login(String email, String password) async {
    final data = await _postJson({
      'accion': 'login',
      'correo': email.trim(),
      'contrasena': password,
    }, keepSessionOnError: true);

    if (data['ok'] == true) {
      final rolCrudo = (data['rol'] ?? '').toString();
      final rolNormalizado = rolCrudo.toLowerCase();
      final permitido = rolNormalizado.isEmpty ||
          _rolesPermitidos.any((r) => rolNormalizado.contains(r));
      if (!permitido) {
        clearSession();
        return const LoginResult(
          ok: false,
          message: 'Esta app solo permite acceso de cuentadantes y tecnicos.',
        );
      }
      _userId = asInt(data['idUsuario'] ?? data['id']);
      _role = rolCrudo.isEmpty ? null : rolCrudo;
      return LoginResult(ok: true, userId: _userId, role: _role);
    }

    clearSession();
    return LoginResult(
      ok: false,
      message: (data['mensaje'] ?? 'Correo o contrasena incorrectos.').toString(),
    );
  }

  Future<void> logout() async {
    try {
      await _postJson({'accion': 'logout'});
    } finally {
      clearSession();
    }
  }

  void clearSession() {
    _cookies.clear();
    _userId = null;
    _role = null;
  }

  Future<DashboardSummary> dashboardSummary() async {
    final data = await _getJson(_withUser({'accion': 'resumen'}));
    return DashboardSummary.fromJson(data);
  }

  Future<List<Machine>> assignedMachines() async {
    final data = await _getList(_withUser({'accion': 'maquinasAsignadas'}));
    return data.map(Machine.fromJson).toList();
  }

  Future<List<MaintenanceItem>> maintenance() async {
    final data = await _getList(_withUser({'accion': 'mantenimientos'}));
    return data.map(MaintenanceItem.fromJson).toList();
  }

  Future<List<ManualItem>> manuals() async {
    final data = await _getList(_withUser({'accion': 'manuales'}));
    return data.map(ManualItem.fromJson).toList();
  }

  /// Catalogo completo de sedes/areas/ambientes registrados en la base
  /// de datos (no depende de las maquinas asignadas al usuario).
  Future<List<String>> sedesCatalog() => _getStringList({'accion': 'sedes'});

  Future<List<String>> areasCatalog() => _getStringList({'accion': 'areas'});

  Future<List<String>> ambientesCatalog() =>
      _getStringList({'accion': 'ambientes'});

  Future<void> reportFailure({
    required int machineId,
    required String description,
  }) async {
    final data = await _postJson(_withUser({
      'accion': 'reportarFalla',
      'idMaquina': '$machineId',
      'descripcion': description,
    }));
    _throwIfNotOk(data);
  }

  /// Solo para el rol Tecnico: mantenimientos asignados que aun no ha
  /// reportado como reparados.
  Future<List<RepairPending>> pendingRepairs() async {
    final data = await _getList(_withUser({'accion': 'reparacionesPendientes'}));
    return data.map(RepairPending.fromJson).toList();
  }

  /// Solo para el rol Tecnico: cierra un mantenimiento asignado adjuntando
  /// la evidencia fotografica del arreglo (obligatoria). Equivalente movil
  /// de "Confirmar reparacion" en la web, pero con foto.
  Future<void> reportRepair({
    required int historialId,
    required String observation,
    required List<File> photos,
  }) async {
    if (photos.isEmpty) {
      throw const ApiException('Adjunta al menos una foto de evidencia.');
    }

    final request = http.MultipartRequest('POST', baseUri);
    request.headers.addAll(_headers());
    request.fields['accion'] = 'reportarArreglo';
    request.fields['idHistorial'] = '$historialId';
    request.fields['observacion'] = observation;
    final userId = _userId;
    if (userId != null && userId > 0) {
      request.fields['idUsuario'] = '$userId';
    }
    for (final photo in photos) {
      request.files.add(await http.MultipartFile.fromPath('foto', photo.path));
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    _saveCookies(response.headers);
    _ensureOk(response);
    final data = _decodeMap(response.body);
    _throwIfNotOk(data);
  }

  Future<Map<String, dynamic>> _getJson(Map<String, String> query) async {
    final response = await _client.get(_uri(query), headers: _headers());
    _saveCookies(response.headers);
    _ensureOk(response);
    return _decodeMap(response.body);
  }

  Future<List<Map<String, dynamic>>> _getList(Map<String, String> query) async {
    final response = await _client.get(_uri(query), headers: _headers());
    _saveCookies(response.headers);
    _ensureOk(response);
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    throw const ApiException('Respuesta inesperada del servidor.');
  }

  /// Decodifica una respuesta que es un array plano de strings, como
  /// ["BRONX","COMPLEJO SUR"] (usado por los catalogos de sedes/areas/
  /// ambientes).
  Future<List<String>> _getStringList(Map<String, String> query) async {
    final response = await _client.get(_uri(query), headers: _headers());
    _saveCookies(response.headers);
    _ensureOk(response);
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded.map((item) => item.toString()).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> _postJson(
    Map<String, String> body, {
    bool keepSessionOnError = false,
  }) async {
    final response = await _client.post(baseUri, headers: _headers(), body: body);
    _saveCookies(response.headers);
    _ensureOk(response, keepSessionOnError: keepSessionOnError);
    return _decodeMap(response.body);
  }

  Uri _uri(Map<String, String> query) {
    return baseUri.replace(queryParameters: query);
  }

  Map<String, String> _withUser(Map<String, String> values) {
    final userId = _userId;
    return {
      ...values,
      if (userId != null && userId > 0) 'idUsuario': '$userId',
    };
  }

  Map<String, String> _headers() {
    return {
      if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
      'Accept': 'application/json,text/html',
    };
  }

  void _saveCookies(Map<String, String> headers) {
    final rawCookie = headers['set-cookie'];
    if (rawCookie == null || rawCookie.isEmpty) return;
    for (final part in rawCookie.split(',')) {
      final cookie = part.split(';').first;
      final index = cookie.indexOf('=');
      if (index > 0) {
        _cookies[cookie.substring(0, index).trim()] =
            cookie.substring(index + 1).trim();
      }
    }
  }

  void _ensureOk(
    http.Response response, {
    bool keepSessionOnError = false,
  }) {
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('text/html')) {
      if (!keepSessionOnError) clearSession();
      throw const ApiException('El servidor no entrego una respuesta movil.');
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (!keepSessionOnError) clearSession();
      throw const ApiException('La sesion vencio. Inicia sesion de nuevo.');
    }
    if (response.statusCode >= 400) {
      throw ApiException('Error del servidor: ${response.statusCode}.');
    }
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw const ApiException('Respuesta inesperada del servidor.');
  }

  void _throwIfNotOk(Map<String, dynamic> data) {
    if (data['ok'] != true) {
      throw ApiException(
        (data['mensaje'] ?? 'No se pudo completar la accion.').toString(),
      );
    }
  }
}
