import 'json_helpers.dart';

/// Rol habilitado para autoregistro publico (Aprendiz, Instructor, Tecnico,
/// Logistica). Administrador, Cuentadante y Subdireccion solo los crea un
/// administrador desde la web, igual que en el sistema NetBeans.
class RegisterRole {
  const RegisterRole({required this.idRol, required this.nombre});

  final int idRol;
  final String nombre;

  factory RegisterRole.fromJson(Map<String, dynamic> json) {
    return RegisterRole(
      idRol: asInt(json['idRol']),
      nombre: (json['nombre'] ?? '').toString(),
    );
  }
}
