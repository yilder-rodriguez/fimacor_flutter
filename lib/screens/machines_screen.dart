import 'package:flutter/material.dart';

import '../models/machine.dart';
import '../services/api_client.dart';
import '../widgets/app_snack.dart';
import '../widgets/empty_state.dart';
import '../widgets/future_panel.dart';
import '../widgets/info_card.dart';
import 'report_failure_dialog.dart';

/// Datos combinados que necesita la pantalla: las maquinas asignadas
/// al cuentadante, mas los catalogos completos de sede/area/ambiente
/// (estos ultimos NO dependen de lo que tenga asignado el usuario,
/// muestran todo lo que existe en la base de datos).
class _MachinesData {
  _MachinesData({
    required this.machines,
    required this.sedes,
    required this.areas,
    required this.ambientes,
  });

  final List<Machine> machines;
  final List<String> sedes;
  final List<String> areas;
  final List<String> ambientes;
}

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  late Future<_MachinesData> _future;
  String? selectedSede;
  String? selectedArea;
  String? selectedAmbiente;

  @override
  void initState() {
    super.initState();
    _future = _cargarDatos();
  }

  Future<_MachinesData> _cargarDatos() async {
    final resultados = await Future.wait([
      widget.api.assignedMachines(),
      widget.api.sedesCatalog(),
      widget.api.areasCatalog(),
      widget.api.ambientesCatalog(),
    ]);

    return _MachinesData(
      machines: resultados[0] as List<Machine>,
      sedes: resultados[1] as List<String>,
      areas: resultados[2] as List<String>,
      ambientes: resultados[3] as List<String>,
    );
  }

  void _recargar() {
    setState(() => _future = _cargarDatos());
  }

  Future<void> _reportFailure(Machine machine) async {
    final description = await showDialog<String>(
      context: context,
      builder: (_) => ReportFailureDialog(machine: machine),
    );
    if (description == null || description.trim().isEmpty) return;

    try {
      await widget.api.reportFailure(
        machineId: machine.id,
        description: description.trim(),
      );
      if (!mounted) return;
      showAppSnack(context, 'Novedad registrada.');
      _recargar();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FuturePanel<_MachinesData>(
      mensajeCarga: 'Cargando maquinas...',
      future: _future,
      onRefresh: _recargar,
      builder: (context, data) {
        if (data.machines.isEmpty) {
          return const EmptyState(text: 'No tienes maquinas asignadas.');
        }

        String? sedeOf(Machine m) =>
            (m.sede != null && m.sede!.trim().isNotEmpty) ? m.sede!.trim() : null;
        String? areaOf(Machine m) =>
            (m.area != null && m.area!.trim().isNotEmpty) ? m.area!.trim() : null;
        String? ambienteOf(Machine m) => (m.ambiente != null && m.ambiente!.trim().isNotEmpty)
            ? m.ambiente!.trim()
            : null;

        final filtered = data.machines.where((m) {
          if (selectedSede != null && sedeOf(m) != selectedSede) return false;
          if (selectedArea != null && areaOf(m) != selectedArea) return false;
          if (selectedAmbiente != null && ambienteOf(m) != selectedAmbiente) return false;
          return true;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: selectedSede,
                            decoration: const InputDecoration(labelText: 'Sede'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              ...data.sedes.map(
                                (s) => DropdownMenuItem(value: s, child: Text(s)),
                              ),
                            ],
                            onChanged: (v) => setState(() => selectedSede = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: selectedArea,
                            decoration: const InputDecoration(labelText: 'Área'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              ...data.areas.map(
                                (s) => DropdownMenuItem(value: s, child: Text(s)),
                              ),
                            ],
                            onChanged: (v) => setState(() => selectedArea = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: selectedAmbiente,
                            decoration: const InputDecoration(labelText: 'Ambiente'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              ...data.ambientes.map(
                                (s) => DropdownMenuItem(value: s, child: Text(s)),
                              ),
                            ],
                            onChanged: (v) => setState(() => selectedAmbiente = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(text: 'No hay maquinas con ese filtro.')
                  : ListView.separated(
                      padding: const EdgeInsets.all(18),
                      itemBuilder: (context, index) {
                        final machine = filtered[index];
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: InfoCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F3FF),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.precision_manufacturing_rounded,
                                          color: Color(0xFF2666A3),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              machine.code.isEmpty
                                                  ? machine.description
                                                  : machine.code,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(fontWeight: FontWeight.w800),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              [
                                                machine.description,
                                                '${machine.brand} ${machine.model}'.trim(),
                                                [
                                                  machine.sede?.trim(),
                                                  machine.area?.trim(),
                                                  machine.ambiente?.trim(),
                                                ]
                                                    .where((text) =>
                                                        text != null && text.isNotEmpty)
                                                    .cast<String>()
                                                    .join(' - '),
                                              ]
                                                  .where((text) => text.trim().isNotEmpty)
                                                  .join(' - '),
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
                                      if (machine.status.trim().isNotEmpty)
                                        Chip(
                                          avatar: const Icon(Icons.info_outline, size: 18),
                                          label: Text(machine.status),
                                        ),
                                      FilledButton.tonalIcon(
                                        onPressed: () => _reportFailure(machine),
                                        icon: const Icon(Icons.report_problem_outlined),
                                        label: const Text('Reportar falla'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: filtered.length,
                    ),
            ),
          ],
        );
      },
    );
  }
}
