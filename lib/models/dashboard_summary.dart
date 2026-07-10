import 'json_helpers.dart';

class DashboardSummary {
  DashboardSummary({
    required this.assignedMachines,
    required this.pendingMaintenance,
    required this.manuals,
    required this.openReports,
  });

  final int assignedMachines;
  final int pendingMaintenance;
  final int manuals;
  final int openReports;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      assignedMachines: asInt(json['maquinasAsignadas']),
      pendingMaintenance: asInt(json['mantenimientosPendientes']),
      manuals: asInt(json['manuales']),
      openReports: asInt(json['novedadesAbiertas']),
    );
  }
}
