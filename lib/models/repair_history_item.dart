import 'json_helpers.dart';

/// Historial COMPLETO (pendientes + reparados) de un Tecnico. Viene de
/// accion=historialTecnico en MobileApiServlet, equivalente movil de
/// "sus" filas en Historial_mantenimiento.jsp, con los campos de
/// descripcion_accion ya separados por el servidor.
class RepairHistoryItem {
  RepairHistoryItem({
    required this.historialId,
    required this.machineId,
    required this.machineCode,
    required this.description,
    required this.completed,
    required this.startDate,
    required this.nextDate,
    required this.tasks,
    required this.maintenanceType,
    required this.repairDate,
    required this.observation,
  });

  final int historialId;
  final int machineId;
  final String machineCode;
  final String description;
  final bool completed;
  final String startDate;
  final String nextDate;
  final String tasks;
  final String maintenanceType;
  final String repairDate;
  final String observation;

  factory RepairHistoryItem.fromJson(Map<String, dynamic> json) {
    return RepairHistoryItem(
      historialId: asInt(json['idHistorial']),
      machineId: asInt(json['idMaquina']),
      machineCode: (json['codigoSena'] ?? '').toString(),
      description: (json['descripcion'] ?? '').toString(),
      completed: (json['estado'] ?? '').toString().toUpperCase() == 'REPARADO',
      startDate: (json['fechaInicio'] ?? '').toString(),
      nextDate: (json['fechaProximoMantenimiento'] ?? '').toString(),
      tasks: (json['tareas'] ?? '').toString(),
      maintenanceType: (json['tipoMantenimiento'] ?? '').toString(),
      repairDate: (json['fechaReparacion'] ?? '').toString(),
      observation: (json['observacion'] ?? '').toString(),
    );
  }
}
