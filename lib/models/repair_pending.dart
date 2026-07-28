import 'json_helpers.dart';

/// Mantenimiento asignado a un tecnico que sigue en "ESTADO: ASIGNADO"
/// (aun no reportado como reparado). Viene de
/// accion=reparacionesPendientes en MobileApiServlet, equivalente movil
/// de las filas "Confirmar" que ve el tecnico en
/// Historial_mantenimiento.jsp.
class RepairPending {
  RepairPending({
    required this.historialId,
    required this.machineId,
    required this.machineCode,
    required this.description,
    required this.tecnico,
    required this.startDate,
    required this.nextDate,
    required this.tasks,
    required this.evidence,
  });

  final int historialId;
  final int machineId;
  final String machineCode;
  final String description;
  final String tecnico;
  final String startDate;
  final String nextDate;
  final String tasks;
  final String evidence;

  factory RepairPending.fromJson(Map<String, dynamic> json) {
    return RepairPending(
      historialId: asInt(json['idHistorial']),
      machineId: asInt(json['idMaquina']),
      machineCode: (json['codigoSena'] ?? '').toString(),
      description: (json['descripcion'] ?? '').toString(),
      tecnico: (json['tecnico'] ?? '').toString(),
      startDate: (json['fechaInicio'] ?? '').toString(),
      nextDate: (json['fechaProximoMantenimiento'] ?? '').toString(),
      tasks: (json['tareas'] ?? '').toString(),
      evidence: (json['evidencia'] ?? '').toString(),
    );
  }
}
