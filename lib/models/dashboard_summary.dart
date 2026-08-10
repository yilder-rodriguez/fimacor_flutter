import 'json_helpers.dart';

class DashboardSummary {
  DashboardSummary({
    required this.assignedMachines,
    required this.pendingMaintenance,
    required this.manuals,
    required this.openReports,
    required this.pendingRepairs,
  });

  final int assignedMachines;
  final int pendingMaintenance;
  final int manuals;
  final int openReports;

  /// Solo aplica al rol Tecnico: reparaciones asignadas que aun le falta
  /// reportar. Para Cuentadante siempre es 0 (usa `openReports` en su
  /// lugar, que si refleja algo que puede reportar).
  final int pendingRepairs;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      assignedMachines: asInt(json['maquinasAsignadas']),
      pendingMaintenance: asInt(json['mantenimientosPendientes']),
      manuals: asInt(json['manuales']),
      openReports: asInt(json['novedadesAbiertas']),
      pendingRepairs: asInt(json['reparacionesPendientes']),
    );
  }
}
