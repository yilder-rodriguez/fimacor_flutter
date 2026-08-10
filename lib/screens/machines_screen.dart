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

/// Para el rol Tecnico, la pantalla de Maquinas tiene dos alcances (igual
/// que en la web: Mis_maquinas_asignadas.jsp para lo propio, y
/// Maquinas_registradas.jsp que lista TODO el catalogo). `mine` son las
/// maquinas que tiene a cargo mientras estan en mantenimiento; `all` es
/// el catalogo completo, de solo lectura, para consulta.
enum _MachineScope { mine, all }

class _MachinesScreenState extends State<MachinesScreen> {
  late Future<List<Machine>> _future;
  _MachineScope _scope = _MachineScope.mine;
  String? selectedSede;
  String? selectedArea;
  String? selectedAmbiente;
  List<String> sedes = [];
  List<String> areas = [];
  List<String> ambientes = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Machine>> _load() {
    if (widget.api.isTecnico && _scope == _MachineScope.all) {
      return widget.api.allMachines();
    }
    return widget.api.assignedMachines();
  }

  void _changeScope(_MachineScope scope) {
    if (scope == _scope) return;
    setState(() {
      _scope = scope;
      selectedSede = null;
      selectedArea = null;
      selectedAmbiente = null;
      _future = _load();
    });
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
      setState(() => _future = _load());
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scopeSelector = widget.api.isTecnico
        ? Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<_MachineScope>(
                    segments: const [
                      ButtonSegment(
                        value: _MachineScope.mine,
                        label: Text('Mis maquinas'),
                        icon: Icon(Icons.build_circle_outlined),
                      ),
                      ButtonSegment(
                        value: _MachineScope.all,
                        label: Text('Todas'),
                        icon: Icon(Icons.list_alt_outlined),
                      ),
                    ],
                    selected: {_scope},
                    onSelectionChanged: (selection) => _changeScope(selection.first),
                  ),
                ),
              ),
            ),
          )
        : null;

    return Column(
      children: [
        if (scopeSelector != null) scopeSelector,
        Expanded(
          child: FuturePanel<List<Machine>>(
            mensajeCarga: 'Cargando maquinas...',
            future: _future,
            onRefresh: () => setState(() => _future = _load()),
            builder: (context, allMachines) {
              // "Mis maquinas": solo las que el tecnico tiene a cargo
              // MIENTRAS estan en mantenimiento (para hacer su reparacion).
              // "Todas": el catalogo completo, sin filtrar por estado,
              // igual que Maquinas_registradas.jsp en la web.
              final machines = widget.api.isTecnico && _scope == _MachineScope.mine
                  ? allMachines
                      .where((m) => m.status.toLowerCase().contains('mantenimiento'))
                      .toList()
                  : allMachines;

              if (machines.isEmpty) {
                return EmptyState(
                  text: widget.api.isTecnico && _scope == _MachineScope.mine
                      ? 'No tienes maquinas en mantenimiento en este momento.'
                      : widget.api.isTecnico
                          ? 'No hay maquinas registradas.'
                          : 'No tienes maquinas asignadas.',
                );
              }
        // helpers que usan los campos `sede/area/ambiente` si existen,
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
                            isExpanded: true,
                            initialValue: selectedSede,
                            decoration: const InputDecoration(labelText: 'Sede'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              ...sedes.map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, overflow: TextOverflow.ellipsis),
                                ),
                              ),
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
                            isExpanded: true,
                            initialValue: selectedArea,
                            decoration: const InputDecoration(labelText: 'Área'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              ...areas.map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, overflow: TextOverflow.ellipsis),
                                ),
                              ),
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
                            isExpanded: true,
                            initialValue: selectedAmbiente,
                            decoration: const InputDecoration(labelText: 'Ambiente'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              ...ambientes.map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, overflow: TextOverflow.ellipsis),
                                ),
                              ),
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
                      child: _MachineCard(
                        machine: machine,
                        onReportFailure:
                            widget.api.isTecnico ? null : () => _reportFailure(machine),
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
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de una maquina asignada. Muestra solo el codigo y el estado
/// por defecto; el resto de la informacion (descripcion, marca/modelo,
/// ubicacion) se despliega al presionar "Mostrar informacion".
class _MachineCard extends StatefulWidget {
  const _MachineCard({required this.machine, required this.onReportFailure});

  final Machine machine;
  // Null para el rol Tecnico: reportar falla es exclusivo de cuentadantes,
  // el tecnico usa la pestana "Mantenimiento" para reportar el arreglo.
  final VoidCallback? onReportFailure;

  @override
  State<_MachineCard> createState() => _MachineCardState();
}

class _MachineCardState extends State<_MachineCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final machine = widget.machine;
    final detalle = [
      machine.description,
      '${machine.brand} ${machine.model}'.trim(),
      [
        machine.sede?.trim(),
        machine.area?.trim(),
        machine.ambiente?.trim(),
      ].where((text) => text != null && text.isNotEmpty).cast<String>().join(' - '),
    ].where((text) => text.trim().isNotEmpty).join(' - ');

    return InfoCard(
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
                child: Text(
                  machine.code.isEmpty ? machine.description : machine.code,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState:
                _expandido ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 10, left: 58),
              child: Text(
                detalle.isEmpty ? 'Sin informacion adicional.' : detalle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
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
              OutlinedButton.icon(
                onPressed: () => setState(() => _expandido = !_expandido),
                icon: Icon(
                  _expandido
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                label: Text(_expandido ? 'Ocultar información' : 'Mostrar información'),
              ),
              if (widget.onReportFailure != null)
                FilledButton.tonalIcon(
                  onPressed: widget.onReportFailure,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Reportar falla'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
