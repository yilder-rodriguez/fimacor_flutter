import 'json_helpers.dart';

/// Rol con sus permisos asignados y cuantos usuarios lo tienen, tal
/// como lo entrega accion=adminRolPermisos.
class AdminRolPermisos {
  const AdminRolPermisos({
    required this.idRol,
    required this.nombre,
    required this.totalUsuarios,
    required this.rolTotal,
    required this.permisos,
  });

  final int idRol;
  final String nombre;
  final int totalUsuarios;

  /// true si es un rol con permisos totales (ej. Administrador): siempre
  /// puede hacer todo, sin depender de la lista de permisos asignados.
  final bool rolTotal;
  final Set<int> permisos;

  factory AdminRolPermisos.fromJson(Map<String, dynamic> json) {
    final lista = json['permisos'];
    return AdminRolPermisos(
      idRol: asInt(json['idRol']),
      nombre: (json['nombre'] ?? '').toString(),
      totalUsuarios: asInt(json['totalUsuarios']),
      rolTotal: json['rolTotal'] == true,
      permisos: lista is List ? lista.map(asInt).toSet() : <int>{},
    );
  }
}

/// Permiso disponible en el sistema (equivalente movil de una fila de
/// Permisos.jsp).
class AdminPermiso {
  const AdminPermiso({
    required this.idPermiso,
    required this.codigo,
    required this.descripcion,
  });

  final int idPermiso;
  final String codigo;
  final String descripcion;

  factory AdminPermiso.fromJson(Map<String, dynamic> json) {
    return AdminPermiso(
      idPermiso: asInt(json['idPermiso']),
      codigo: (json['codigo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
    );
  }
}
