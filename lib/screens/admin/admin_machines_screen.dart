import 'package:flutter/material.dart';

import '../../models/admin_machine.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/future_panel.dart';
import '../../widgets/info_card.dart';
import 'admin_machine_form_dialog.dart';

/// Modulo "Maquinas" del panel de Administrador. Equivalente movil de
/// Maquinas_registradas.jsp: listar, buscar, crear, editar y eliminar
/// fichas de maquina.
class AdminMachinesScreen extends StatefulWidget {
  const AdminMachinesScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<AdminMachinesScreen> createState() => _AdminMachinesScreenState();
}

class _AdminMachinesScreenState extends State<AdminMachinesScreen> {
  late Future<_MachinesData> _future;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<_MachinesData> _load() async {
    final results = await Future.wait([
      widget.api.adminMachines(),
      widget.api.adminMachineCatalogs(),
    ]);
    return _MachinesData(
      maquinas: results[0] as List<AdminMachine>,
      catalogos: results[1] as MachineCatalogs,
    );
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _crearOEditar(MachineCatalogs catalogos, {AdminMachine? maquina}) async {
    if (catalogos.marcas.isEmpty || catalogos.tipos.isEmpty || catalogos.sedes.isEmpty) {
      showAppSnack(
        context,
        'Primero crea marcas, modelos, tipos, sedes y ambientes en Catalogos.',
      );
      return;
    }
    final valores = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AdminMachineFormDialog(catalogos: catalogos, maquina: maquina),
    );
    if (valores == null) return;

    try {
      await widget.api.adminSaveMachine(
        idMaquinaObjetivo: maquina?.idMaquina,
        codigoSena: valores['codigoSena'] as String,
        descripcion: valores['descripcion'] as String,
        idMarca: valores['idMarca'] as int,
        idModelo: valores['idModelo'] as int,
        idTipo: valores['idTipo'] as int,
        idAmbiente: valores['idAmbiente'] as int,
        idSede: valores['idSede'] as int,
        idEstado: valores['idEstado'] as int,
        area: valores['area'] as String,
        fechaCompra: valores['fechaCompra'] as String,
        valorMaquina: valores['valorMaquina'] as String,
        tieneGarantia: valores['tieneGarantia'] as bool,
        fechaGarantia: valores['fechaGarantia'] as String,
      );
      if (!mounted) return;
      showAppSnack(context, maquina == null ? 'Maquina creada.' : 'Maquina actualizada.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  Future<void> _eliminar(AdminMachine maquina) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar maquina'),
        content: Text(
          '¿Eliminar ${maquina.codigoSena} - ${maquina.descripcion}? '
          'Tambien se borra su historial y programacion de mantenimiento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await widget.api.adminDeleteMachine(maquina.idMaquina);
      if (!mounted) return;
      showAppSnack(context, 'Maquina eliminada.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maquinas')),
      body: FuturePanel<_MachinesData>(
        mensajeCarga: 'Cargando maquinas...',
        future: _future,
        onRefresh: _refresh,
        builder: (context, data) {
          final q = _query.trim().toLowerCase();
          final filtradas = data.maquinas.where((m) {
            if (q.isEmpty) return true;
            return m.codigoSena.toLowerCase().contains(q) ||
                m.descripcion.toLowerCase().contains(q) ||
                m.marca.toLowerCase().contains(q) ||
                m.modelo.toLowerCase().contains(q) ||
                m.sede.toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: TextField(
                      controller: _search,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar por codigo SENA, descripcion, marca o sede',
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Row(
                      children: [
                        Text(
                          '${filtradas.length} de ${data.maquinas.length} maquinas',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filtradas.isEmpty
                    ? const EmptyState(
                        text: 'No se encontraron maquinas con ese criterio.',
                        icon: Icons.precision_manufacturing_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(18),
                        itemCount: filtradas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final maquina = filtradas[index];
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: _MachineCard(
                                maquina: maquina,
                                onEditar: () => _crearOEditar(data.catalogos, maquina: maquina),
                                onEliminar: () => _eliminar(maquina),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<_MachinesData>(
        future: _future,
        builder: (context, snapshot) {
          final catalogos = snapshot.data?.catalogos;
          return FloatingActionButton.extended(
            onPressed: catalogos == null ? null : () => _crearOEditar(catalogos),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nueva maquina'),
          );
        },
      ),
    );
  }
}

class _MachinesData {
  const _MachinesData({required this.maquinas, required this.catalogos});
  final List<AdminMachine> maquinas;
  final MachineCatalogs catalogos;
}

class _MachineCard extends StatelessWidget {
  const _MachineCard({
    required this.maquina,
    required this.onEditar,
    required this.onEliminar,
  });

  final AdminMachine maquina;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.rolAdministrador.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.precision_manufacturing_outlined,
                    color: AppColors.rolAdministrador),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${maquina.codigoSena} · ${maquina.descripcion}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${maquina.marca} ${maquina.modelo}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(avatar: const Icon(Icons.category_outlined, size: 16), label: Text(maquina.tipo)),
              Chip(
                avatar: const Icon(Icons.location_on_outlined, size: 16),
                label: Text('${maquina.sede} · ${maquina.ambiente}'),
              ),
              Chip(
                backgroundColor: maquina.estado.toLowerCase().contains('operativ')
                    ? AppColors.verdeClaroChip
                    : const Color(0xFFFFE9E0),
                label: Text(maquina.estado),
              ),
              if (maquina.tieneGarantia)
                const Chip(
                  avatar: Icon(Icons.verified_user_outlined, size: 16),
                  label: Text('Con garantia'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: onEliminar,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFC0392B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
