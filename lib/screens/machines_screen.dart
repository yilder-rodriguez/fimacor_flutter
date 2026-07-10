import 'package:flutter/material.dart';

import '../models/machine.dart';
import '../services/api_client.dart';
import '../widgets/app_snack.dart';
import '../widgets/empty_state.dart';
import '../widgets/future_panel.dart';
import '../widgets/info_card.dart';
import 'report_failure_dialog.dart';

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  late Future<List<Machine>> _future;
  String? selectedSede;
  String? selectedArea;
  String? selectedAmbiente;
  List<String> sedes = [];
  List<String> areas = [];
  List<String> ambientes = [];

  @override
  void initState() {
    super.initState();
    _future = widget.api.assignedMachines();
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
      setState(() => _future = widget.api.assignedMachines());
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FuturePanel<List<Machine>>(
      future: _future,
      onRefresh: () => setState(() => _future = widget.api.assignedMachines()),
      builder: (context, machines) {
        if (machines.isEmpty) {
          return const EmptyState(text: 'No tienes maquinas asignadas.');
        }
        // helpers que usan los nuevos campos `sede/area/ambiente` si existen,
        // o hacen fallback parseando `location` separado por '-' para compatibilidad.
        List<String> partsOf(String loc) => loc
            .split('-')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        String? sedeOf(Machine m) {
          if (m.sede != null && m.sede!.trim().isNotEmpty) return m.sede!.trim();
          final p = partsOf(m.location);
          return p.isNotEmpty ? p[0] : null;
        }

        String? areaOf(Machine m) {
          if (m.area != null && m.area!.trim().isNotEmpty) return m.area!.trim();
          final p = partsOf(m.location);
          return p.length > 1 ? p[1] : null;
        }

        String? ambienteOf(Machine m) {
          if (m.ambiente != null && m.ambiente!.trim().isNotEmpty) return m.ambiente!.trim();
          final p = partsOf(m.location);
          return p.length > 2 ? p[2] : null;
        }

        // recalcular sedes/areas/ambientes basadas en los datos actuales
        final all = machines;
        sedes = all.map(sedeOf).where((s) => s != null).cast<String>().toSet().toList()..sort();
        if (selectedSede != null && !sedes.contains(selectedSede)) selectedSede = null;

        if (selectedSede != null) {
          areas = all
              .where((m) => sedeOf(m) == selectedSede)
              .map(areaOf)
              .where((s) => s != null)
              .cast<String>()
              .toSet()
              .toList()
            ..sort();
        } else {
          areas = [];
          selectedArea = null;
        }

        if (selectedArea != null) {
          ambientes = all
              .where((m) => sedeOf(m) == selectedSede && areaOf(m) == selectedArea)
              .map(ambienteOf)
              .where((s) => s != null)
              .cast<String>()
              .toSet()
              .toList()
            ..sort();
        } else {
          ambientes = [];
          selectedAmbiente = null;
        }

        final filtered = all.where((m) {
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
                              ...sedes.map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            ],
                            onChanged: (v) => setState(() {
                              selectedSede = v;
                              selectedArea = null;
                              selectedAmbiente = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: selectedArea,
                            decoration: const InputDecoration(labelText: 'Área'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              ...areas.map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            ],
                            onChanged: (v) => setState(() {
                              selectedArea = v;
                              selectedAmbiente = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: selectedAmbiente,
                            decoration: const InputDecoration(labelText: 'Ambiente'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              ...ambientes.map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            ],
                            onChanged: (v) => setState(() {
                              selectedAmbiente = v;
                            }),
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
              child: ListView.separated(
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
                                              .where((text) => text != null && text.isNotEmpty)
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
