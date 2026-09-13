import 'package:flutter/material.dart';

import '../../models/admin_catalog_row.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/future_panel.dart';
import '../../widgets/info_card.dart';
import 'admin_catalog_form_dialog.dart';
import 'catalog_type_config.dart';

/// Pantalla de administracion de UN catalogo (sedes, marcas, modelos,
/// etc.). Es completamente generica: se configura con un
/// CatalogTypeConfig y funciona igual para los 7 catalogos.
class AdminCatalogItemsScreen extends StatefulWidget {
  const AdminCatalogItemsScreen({required this.api, required this.config, super.key});

  final ApiClient api;
  final CatalogTypeConfig config;

  @override
  State<AdminCatalogItemsScreen> createState() => _AdminCatalogItemsScreenState();
}

class _AdminCatalogItemsScreenState extends State<AdminCatalogItemsScreen> {
  late Future<_CatalogData> _future;

  List<String> get _catalogosReferenciados => widget.config.campos
      .where((c) => c.type == CatalogFieldType.referencia)
      .map((c) => c.referenciaCatalogo!)
      .toSet()
      .toList();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CatalogData> _load() async {
    final filas = await widget.api.adminCatalogList(widget.config.key);
    final referencias = <String, List<AdminCatalogRow>>{};
    for (final catalogoRef in _catalogosReferenciados) {
      referencias[catalogoRef] = await widget.api.adminCatalogList(catalogoRef);
    }
    // Vuelve a indexar las referencias por el key del CAMPO (no del
    // catalogo), porque un catalogo podria tener mas de un campo que
    // apunte al mismo catalogo referenciado.
    final opcionesPorCampo = <String, List<AdminCatalogRow>>{};
    for (final campo in widget.config.campos) {
      if (campo.type == CatalogFieldType.referencia) {
        opcionesPorCampo[campo.key] = referencias[campo.referenciaCatalogo!] ?? [];
      }
    }
    return _CatalogData(filas: filas, opcionesPorCampo: opcionesPorCampo);
  }

  void _refresh() => setState(() => _future = _load());

  String _resolverReferencia(CatalogFieldConfig campo, String valorId, List<AdminCatalogRow> opciones) {
    final id = int.tryParse(valorId);
    if (id == null) return valorId;
    final referenciado = kCatalogTypes.firstWhere((c) => c.key == campo.referenciaCatalogo);
    final fila = opciones.where((o) => o.id == id).toList();
    if (fila.isEmpty) return 'ID $id';
    final texto = fila.first.campos[referenciado.campoPrincipal.key] ?? '';
    return texto.isEmpty ? 'ID $id' : texto;
  }

  Future<void> _crearOEditar(_CatalogData data, {AdminCatalogRow? fila}) async {
    for (final campo in widget.config.campos) {
      if (campo.type == CatalogFieldType.referencia &&
          (data.opcionesPorCampo[campo.key] ?? []).isEmpty) {
        showAppSnack(
          context,
          'Primero crea al menos un registro en "${campo.label}".',
        );
        return;
      }
    }
    final valores = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AdminCatalogFormDialog(
        config: widget.config,
        opcionesReferencia: data.opcionesPorCampo,
        fila: fila,
      ),
    );
    if (valores == null) return;

    try {
      await widget.api.adminCatalogSave(
        catalogo: widget.config.key,
        idObjetivo: fila?.id,
        campos: valores,
      );
      if (!mounted) return;
      showAppSnack(context, fila == null ? 'Registro creado.' : 'Registro actualizado.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  Future<void> _eliminar(AdminCatalogRow fila) async {
    final nombre = fila.campos[widget.config.campoPrincipal.key] ?? 'ID ${fila.id}';
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text(
          '¿Eliminar "$nombre"? Si esta en uso por maquinas u otros catalogos, el servidor rechazara el borrado.',
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
      await widget.api.adminCatalogDelete(catalogo: widget.config.key, idObjetivo: fila.id);
      if (!mounted) return;
      showAppSnack(context, 'Registro eliminado.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.titulo)),
      body: FuturePanel<_CatalogData>(
        mensajeCarga: 'Cargando ${widget.config.titulo.toLowerCase()}...',
        future: _future,
        onRefresh: _refresh,
        builder: (context, data) {
          if (data.filas.isEmpty) {
            return EmptyState(
              text: 'Aun no hay registros en ${widget.config.titulo.toLowerCase()}.',
              icon: widget.config.icon,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
            itemCount: data.filas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final fila = data.filas[index];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: InfoCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: widget.config.campos.map((campo) {
                              final valor = fila.campos[campo.key] ?? '';
                              final texto = campo.type == CatalogFieldType.referencia
                                  ? _resolverReferencia(
                                      campo, valor, data.opcionesPorCampo[campo.key] ?? [])
                                  : valor;
                              final esPrincipal = campo.key == widget.config.campoPrincipal.key;
                              return Text(
                                texto,
                                style: esPrincipal
                                    ? Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800)
                                    : Theme.of(context).textTheme.bodySmall,
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: () => _crearOEditar(data, fila: fila),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          onPressed: () => _eliminar(fila),
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: const Color(0xFFC0392B),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<_CatalogData>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return FloatingActionButton.extended(
            onPressed: data == null ? null : () => _crearOEditar(data),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo'),
          );
        },
      ),
    );
  }
}

class _CatalogData {
  const _CatalogData({required this.filas, required this.opcionesPorCampo});
  final List<AdminCatalogRow> filas;
  final Map<String, List<AdminCatalogRow>> opcionesPorCampo;
}
