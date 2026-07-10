import 'json_helpers.dart';

class MaintenanceItem {
  MaintenanceItem({
    required this.id,
    required this.machineCode,
    required this.description,
    required this.nextDate,
    required this.frequency,
    required this.tasks,
  });

  final int id;
  final String machineCode;
  final String description;
  final String nextDate;
  final String frequency;
  final String tasks;

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      id: asInt(json['idMantenimiento'] ?? json['id']),
      machineCode: (json['codigoSena'] ?? json['codigo_sena'] ?? '').toString(),
      description: (json['descripcion'] ?? json['descripcion_Mantenimiento'] ?? '')
          .toString(),
      nextDate: (json['fechaProximoMantenimiento'] ??
              json['fecha_proximo_mantenimiento'] ??
              '')
          .toString(),
      frequency: (json['frecuencia'] ?? '').toString(),
      tasks: (json['tareas'] ?? '').toString(),
    );
  }
}
