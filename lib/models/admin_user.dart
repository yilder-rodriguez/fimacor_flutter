import 'json_helpers.dart';

/// Usuario tal como lo ve el Administrador en su panel de gestion
/// (equivalente movil de una fila de Tabla_usuario.jsp).
class AdminUser {
  const AdminUser({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.telefono,
    required this.correo,
    required this.idRol,
    required this.rol,
    required this.activo,
  });

  final int idUsuario;
  final String nombre;
  final String apellido;
  final String documento;
  final String telefono;
  final String correo;
  final int idRol;
  final String rol;
  final bool activo;

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      idUsuario: asInt(json['idUsuario']),
      nombre: (json['nombre'] ?? '').toString(),
      apellido: (json['apellido'] ?? '').toString(),
      documento: (json['documento'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      idRol: asInt(json['idRol']),
      rol: (json['rol'] ?? '').toString(),
      activo: asInt(json['activo']) != 0,
    );
  }
}

/// Rol disponible para asignar desde el panel de administracion. A
/// diferencia de RegisterRole (autoregistro publico), esta lista incluye
/// TODOS los roles del sistema, porque el Administrador si puede crear
/// Cuentadantes, Subdireccion, etc.
class AdminRole {
  const AdminRole({required this.idRol, required this.nombre});

  final int idRol;
  final String nombre;

  factory AdminRole.fromJson(Map<String, dynamic> json) {
    return AdminRole(
      idRol: asInt(json['idRol']),
      nombre: (json['nombre'] ?? '').toString(),
    );
  }
}
