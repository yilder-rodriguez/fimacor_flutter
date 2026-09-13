import 'package:flutter/material.dart';

import '../models/machine.dart';
import '../services/api_client.dart';
import '../widgets/empty_state.dart';
import '../widgets/future_panel.dart';
import '../widgets/info_card.dart';

/// Catalogo completo de maquinas, solo lectura, para Subdireccion
/// (equivalente movil de Maquinas_registradas.jsp para este rol).
class SubdireccionMachinesScreen extends StatefulWidget {
  const SubdireccionMachinesScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<SubdireccionMachinesScreen> createState() =>
      _SubdireccionMachinesScreenState();
}

class _SubdireccionMachinesScreenState
    extends State<SubdireccionMachinesScreen> {
  late Future<List<Machine>> _future;
  final _search = TextEditingController();
  var _query = '';

  @override
  void initState() {
    super.initState();
    _future = widget.api.allMachines();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _future = widget.api.allMachines());

  @override
  Widget build(BuildContext context) {
    return FuturePanel<List<Machine>>(
      mensajeCarga: 'Cargando maquinas...',
      future: _future,
      onRefresh: _refresh,
      builder: (context, maquinas) {
        final q = _query.trim().toLowerCase();
        final filtradas = maquinas.where((m) {
          if (q.isEmpty) return true;
          return m.code.toLowerCase().contains(q) ||
              m.description.toLowerCase().contains(q) ||
              m.location.toLowerCase().contains(q);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por codigo, descripcion o ubicacion',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(() {
                            _search.clear();
                            _query = '';
                          }),
                        ),
                ),
              ),
            ),
            Expanded(
              child: filtradas.isEmpty
                  ? const EmptyState(
                      text: 'No se encontraron maquinas.',
                      icon: Icons.precision_manufacturing_outlined,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(18),
                      itemCount: filtradas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final m = filtradas[index];
                        return InfoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${m.code} \u00b7 ${m.description}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text('${m.brand} ${m.model}',
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  Chip(label: Text(m.location)),
                                  Chip(label: Text(m.status)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
