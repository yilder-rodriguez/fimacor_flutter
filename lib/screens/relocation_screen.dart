import 'package:flutter/material.dart';

import '../models/relocation.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/app_snack.dart';
import '../widgets/empty_state.dart';
import '../widgets/future_panel.dart';
import '../widgets/info_card.dart';
import 'request_relocation_dialog.dart';

/// Pantalla "Reubicaciones" del Cuentadante: equivalente movil de
/// Reubicacion_maquina.jsp. Permite solicitar mover una maquina y ver el
/// estado de sus solicitudes anteriores.
class RelocationScreen extends StatefulWidget {
  const RelocationScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<RelocationScreen> createState() => _RelocationScreenState();
}

class _RelocationScreenState extends State<RelocationScreen> {
  late Future<_RelocationData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RelocationData> _load() async {
    final results = await Future.wait([
      widget.api.myRelocationRequests(),
      widget.api.relocationCatalogs(),
    ]);
    return _RelocationData(
      solicitudes: results[0] as List<RelocationRequest>,
      catalogos: results[1] as RelocationCatalogs,
    );
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _solicitar(RelocationCatalogs catalogos) async {
    if (catalogos.maquinas.isEmpty || catalogos.ambientes.isEmpty) {
      showAppSnack(context, 'No hay maquinas o ambientes registrados todavia.');
      return;
    }
    final valores = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => RequestRelocationDialog(catalogos: catalogos),
    );
    if (valores == null) return;

    try {
      await widget.api.requestRelocation(
        idMaquina: valores['idMaquina'] as int,
        tipoTraslado: valores['tipoTraslado'] as String,
        origen: valores['origen'] as String,
        destino: valores['destino'] as String,
        idAmbienteDestino: valores['idAmbienteDestino'] as int,
        idSedeDestino: valores['idSedeDestino'] as int?,
        areaDestino: valores['areaDestino'] as String,
        descripcion: valores['descripcion'] as String,
        observacion: valores['observacion'] as String,
        evidencia: valores['evidencia'],
      );
      if (!mounted) return;
      showAppSnack(context, 'Solicitud enviada a Subdireccion.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FuturePanel<_RelocationData>(
      mensajeCarga: 'Cargando reubicaciones...',
      future: _future,
      onRefresh: _refresh,
      builder: (context, data) {
        return Stack(
          children: [
            data.solicitudes.isEmpty
                ? const EmptyState(
                    text: 'Aun no has solicitado ninguna reubicacion.',
                    icon: Icons.move_up_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
                    itemCount: data.solicitudes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _RelocationCard(solicitud: data.solicitudes[index]),
                  ),
            Positioned(
              right: 18,
              bottom: 18,
              child: FloatingActionButton.extended(
                onPressed: () => _solicitar(data.catalogos),
                icon: const Icon(Icons.move_up_rounded),
                label: const Text('Solicitar'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RelocationData {
  const _RelocationData({required this.solicitudes, required this.catalogos});
  final List<RelocationRequest> solicitudes;
  final RelocationCatalogs catalogos;
}

class _RelocationCard extends StatelessWidget {
  const _RelocationCard({required this.solicitud});

  final RelocationRequest solicitud;

  Color get _colorEstado {
    switch (solicitud.estado.toLowerCase()) {
      case 'aprobado':
        return const Color(0xFF1E8E5A);
      case 'rechazado':
        return const Color(0xFFC0392B);
      default:
        return const Color(0xFFB8860B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  solicitud.maquina,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Chip(
                backgroundColor: _colorEstado.withValues(alpha: 0.14),
                label: Text(solicitud.estado, style: TextStyle(color: _colorEstado)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${solicitud.origen} \u2192 ${solicitud.destino}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(solicitud.descripcion, style: Theme.of(context).textTheme.bodySmall),
          if (solicitud.respuesta.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              solicitud.respuesta,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textoLabel),
            ),
          ],
        ],
      ),
    );
  }
}
