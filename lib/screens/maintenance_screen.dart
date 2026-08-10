import 'package:flutter/material.dart';

import '../models/maintenance_item.dart';
import '../models/repair_history_item.dart';
import '../models/repair_pending.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/app_snack.dart';
import '../widgets/empty_state.dart';
import '../widgets/future_panel.dart';
import '../widgets/info_card.dart';
import 'repair_report_dialog.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.api.isTecnico
        ? _TecnicoReparacionesView(api: widget.api)
        : _CuentadanteMantenimientosView(api: widget.api);
  }
}

/// Vista para el rol Cuentadante: proximos mantenimientos programados de
/// sus maquinas (comportamiento original de esta pantalla).
class _CuentadanteMantenimientosView extends StatefulWidget {
  const _CuentadanteMantenimientosView({required this.api});

  final ApiClient api;

  @override
  State<_CuentadanteMantenimientosView> createState() =>
      _CuentadanteMantenimientosViewState();
}

class _CuentadanteMantenimientosViewState
    extends State<_CuentadanteMantenimientosView> {
  late Future<List<MaintenanceItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.maintenance();
  }

  @override
  Widget build(BuildContext context) {
    return FuturePanel<List<MaintenanceItem>>(
      mensajeCarga: 'Cargando mantenimientos...',
      future: _future,
      onRefresh: () => setState(() => _future = widget.api.maintenance()),
      builder: (context, items) {
        if (items.isEmpty) {
          return const EmptyState(text: 'No hay mantenimientos pendientes.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemBuilder: (context, index) {
            final item = items[index];
            return InfoCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.verdeClaroChip,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: AppColors.primario,
                  ),
                ),
                title: Text(
                  item.machineCode.isEmpty
                      ? 'Mantenimiento programado'
                      : item.machineCode,
                ),
                subtitle: Text(
                  [
                    item.description,
                    if (item.nextDate.isNotEmpty) 'Proximo: ${item.nextDate}',
                    item.frequency,
                    item.tasks,
                  ].where((text) => text.trim().isNotEmpty).join('\n'),
                ),
                isThreeLine: true,
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length,
        );
      },
    );
  }
}

/// Alcance dentro de la pestana Mantenimiento del rol Tecnico:
/// `pendientes` son las reparaciones asignadas que aun debe reportar, e
/// `historial` es el registro completo (pendientes + ya reparadas),
/// equivalente movil de sus propias filas en Historial_mantenimiento.jsp.
enum _ReparacionScope { pendientes, historial }

/// Vista para el rol Tecnico: mantenimientos que tiene asignados,
/// pendientes de reportar como reparados (con evidencia fotografica
/// obligatoria) o ya reparados. Equivalente movil de las filas
/// "Confirmar" y del historial completo en Historial_mantenimiento.jsp.
class _TecnicoReparacionesView extends StatefulWidget {
  const _TecnicoReparacionesView({required this.api});

  final ApiClient api;

  @override
  State<_TecnicoReparacionesView> createState() =>
      _TecnicoReparacionesViewState();
}

class _TecnicoReparacionesViewState extends State<_TecnicoReparacionesView> {
  _ReparacionScope _scope = _ReparacionScope.pendientes;
  late Future<List<RepairPending>> _futurePendientes;
  late Future<List<RepairHistoryItem>> _futureHistorial;

  @override
  void initState() {
    super.initState();
    _futurePendientes = widget.api.pendingRepairs();
    _futureHistorial = widget.api.repairHistory();
  }

  void _changeScope(_ReparacionScope scope) {
    if (scope == _scope) return;
    setState(() => _scope = scope);
  }

  void _recargarTodo() {
    setState(() {
      _futurePendientes = widget.api.pendingRepairs();
      _futureHistorial = widget.api.repairHistory();
    });
  }

  Future<void> _reportarArreglo({
    required int historialId,
    required String machineCode,
    required String description,
    required String tasks,
  }) async {
    final result = await showDialog<RepairReportResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RepairReportDialog(
        historialId: historialId,
        machineCode: machineCode,
        description: description,
        tasks: tasks,
      ),
    );
    if (result == null) return;

    try {
      await widget.api.reportRepair(
        historialId: historialId,
        observation: result.observation,
        photos: result.photos,
      );
      if (!mounted) return;
      showAppSnack(context, 'Reparacion reportada. La maquina vuelve a estar operativa.');
      _recargarTodo();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<_ReparacionScope>(
                  segments: const [
                    ButtonSegment(
                      value: _ReparacionScope.pendientes,
                      label: Text('Pendientes'),
                      icon: Icon(Icons.pending_actions_outlined),
                    ),
                    ButtonSegment(
                      value: _ReparacionScope.historial,
                      label: Text('Historial'),
                      icon: Icon(Icons.history_outlined),
                    ),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (selection) => _changeScope(selection.first),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _scope == _ReparacionScope.pendientes
              ? _PendientesList(
                  future: _futurePendientes,
                  onRefresh: () => setState(
                    () => _futurePendientes = widget.api.pendingRepairs(),
                  ),
                  onReportar: (item) => _reportarArreglo(
                    historialId: item.historialId,
                    machineCode: item.machineCode,
                    description: item.description,
                    tasks: item.tasks,
                  ),
                )
              : _HistorialList(
                  future: _futureHistorial,
                  onRefresh: () => setState(
                    () => _futureHistorial = widget.api.repairHistory(),
                  ),
                  onReportar: (item) => _reportarArreglo(
                    historialId: item.historialId,
                    machineCode: item.machineCode,
                    description: item.description,
                    tasks: item.tasks,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Lista de reparaciones asignadas que el tecnico aun no reporta.
class _PendientesList extends StatelessWidget {
  const _PendientesList({
    required this.future,
    required this.onRefresh,
    required this.onReportar,
  });

  final Future<List<RepairPending>> future;
  final VoidCallback onRefresh;
  final ValueChanged<RepairPending> onReportar;

  @override
  Widget build(BuildContext context) {
    return FuturePanel<List<RepairPending>>(
      mensajeCarga: 'Cargando reparaciones pendientes...',
      future: future,
      onRefresh: onRefresh,
      builder: (context, items) {
        if (items.isEmpty) {
          return const EmptyState(
            text: 'No tienes reparaciones pendientes por reportar.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemBuilder: (context, index) {
            final item = items[index];
            return InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9E0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.handyman_outlined,
                          color: Color(0xFFC65A2E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.machineCode.isEmpty
                                  ? item.description
                                  : item.machineCode,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                item.description,
                                if (item.tasks.trim().isNotEmpty)
                                  'Tareas: ${item.tasks}',
                                if (item.nextDate.isNotEmpty)
                                  'Fecha limite: ${item.nextDate}',
                              ].where((t) => t.trim().isNotEmpty).join('\n'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Chip(
                        avatar: Icon(Icons.pending_actions_outlined, size: 18),
                        label: Text('Pendiente por reportar'),
                      ),
                      FilledButton.icon(
                        onPressed: () => onReportar(item),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Reportar arreglo'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length,
        );
      },
    );
  }
}

/// Historial completo (pendientes + reparadas) de las reparaciones del
/// tecnico, equivalente movil de sus propias filas en
/// Historial_mantenimiento.jsp.
class _HistorialList extends StatelessWidget {
  const _HistorialList({
    required this.future,
    required this.onRefresh,
    required this.onReportar,
  });

  final Future<List<RepairHistoryItem>> future;
  final VoidCallback onRefresh;
  final ValueChanged<RepairHistoryItem> onReportar;

  @override
  Widget build(BuildContext context) {
    return FuturePanel<List<RepairHistoryItem>>(
      mensajeCarga: 'Cargando historial...',
      future: future,
      onRefresh: onRefresh,
      builder: (context, items) {
        if (items.isEmpty) {
          return const EmptyState(
            text: 'Aun no tienes mantenimientos en tu historial.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemBuilder: (context, index) {
            final item = items[index];
            return InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.completed
                              ? AppColors.verdeClaroChip
                              : const Color(0xFFFFE9E0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.completed
                              ? Icons.check_circle_outline
                              : Icons.handyman_outlined,
                          color: item.completed
                              ? AppColors.primario
                              : const Color(0xFFC65A2E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.machineCode.isEmpty
                                  ? item.description
                                  : item.machineCode,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                item.description,
                                if (item.maintenanceType.trim().isNotEmpty)
                                  'Tipo: ${item.maintenanceType}',
                                if (item.tasks.trim().isNotEmpty)
                                  'Tareas: ${item.tasks}',
                                if (item.startDate.isNotEmpty)
                                  'Asignado: ${item.startDate}',
                                if (item.completed && item.repairDate.isNotEmpty)
                                  'Reparado: ${item.repairDate}',
                                if (item.completed && item.observation.isNotEmpty)
                                  'Observacion: ${item.observation}',
                              ].where((t) => t.trim().isNotEmpty).join('\n'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        avatar: Icon(
                          item.completed
                              ? Icons.check_circle_outline
                              : Icons.pending_actions_outlined,
                          size: 18,
                        ),
                        label: Text(item.completed ? 'Reparado' : 'Pendiente'),
                      ),
                      if (!item.completed)
                        FilledButton.icon(
                          onPressed: () => onReportar(item),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Reportar arreglo'),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length,
        );
      },
    );
  }
}
