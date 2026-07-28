import 'package:flutter/material.dart';

import '../models/maintenance_item.dart';
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

/// Vista para el rol Tecnico: mantenimientos que tiene asignados y estan
/// pendientes de reportar como reparados, con evidencia fotografica
/// obligatoria. Equivalente movil de las filas "Confirmar" en
/// Historial_mantenimiento.jsp.
class _TecnicoReparacionesView extends StatefulWidget {
  const _TecnicoReparacionesView({required this.api});

  final ApiClient api;

  @override
  State<_TecnicoReparacionesView> createState() =>
      _TecnicoReparacionesViewState();
}

class _TecnicoReparacionesViewState extends State<_TecnicoReparacionesView> {
  late Future<List<RepairPending>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.pendingRepairs();
  }

  Future<void> _reportarArreglo(RepairPending pending) async {
    final result = await showDialog<RepairReportResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RepairReportDialog(pending: pending),
    );
    if (result == null) return;

    try {
      await widget.api.reportRepair(
        historialId: pending.historialId,
        observation: result.observation,
        photos: result.photos,
      );
      if (!mounted) return;
      showAppSnack(context, 'Reparacion reportada. La maquina vuelve a estar operativa.');
      setState(() => _future = widget.api.pendingRepairs());
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FuturePanel<List<RepairPending>>(
      mensajeCarga: 'Cargando reparaciones pendientes...',
      future: _future,
      onRefresh: () => setState(() => _future = widget.api.pendingRepairs()),
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
                        onPressed: () => _reportarArreglo(item),
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
