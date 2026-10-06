import 'package:flutter/material.dart';

import '../models/relocation.dart';
import '../services/api_client.dart';
import '../widgets/app_snack.dart';
import '../widgets/empty_state.dart';
import '../widgets/future_panel.dart';
import '../widgets/info_card.dart';
import '../widgets/signature_pad.dart';
import 'request_relocation_dialog.dart';

/// Reubicaciones: permite solicitar y, para Cuentadante, autorizar las
/// solicitudes internas de sus propias maquinas.
class RelocationScreen extends StatefulWidget {
  const RelocationScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<RelocationScreen> createState() => _RelocationScreenState();
}

class _RelocationScreenState extends State<RelocationScreen> {
  late Future<_RelocationData> _future;
  var _tab = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RelocationData> _load() async {
    final futures = <Future<dynamic>>[
      widget.api.myRelocationRequests(),
      widget.api.relocationCatalogs(),
    ];
    if (widget.api.isCuentadante) futures.add(widget.api.pendingRelocationRequests());
    final results = await Future.wait(futures);
    return _RelocationData(
      solicitudes: results[0] as List<RelocationRequest>,
      catalogos: results[1] as RelocationCatalogs,
      pendientes: widget.api.isCuentadante && results.length > 2
          ? results[2] as List<RelocationRequest>
          : const [],
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
      showAppSnack(context, 'Solicitud de reubicacion enviada correctamente.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  Future<void> _responder(RelocationRequest solicitud) async {
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _DecisionDialog(solicitud: solicitud),
    );
    if (resultado == null) return;
    try {
      await widget.api.respondRelocation(
        idReubicacion: solicitud.idReubicacion,
        aprobar: resultado['aprobar'] as bool,
        firmaDigitalBase64: resultado['firma'] as String,
        observacion: resultado['observacion'] as String,
      );
      if (!mounted) return;
      showAppSnack(context, (resultado['aprobar'] as bool)
          ? 'Reubicacion interna autorizada.'
          : 'Reubicacion rechazada.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final puedeAutorizar = widget.api.isCuentadante;
    return FuturePanel<_RelocationData>(
      mensajeCarga: 'Cargando reubicaciones...',
      future: _future,
      onRefresh: _refresh,
      builder: (context, data) {
        final tabs = <Widget>[const Text('Mis solicitudes')];
        if (puedeAutorizar) tabs.add(const Text('Autorizar internas'));
        return Column(
          children: [
            if (puedeAutorizar)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: SegmentedButton<int>(
                  segments: tabs.asMap().entries.map((entry) => ButtonSegment<int>(
                    value: entry.key,
                    label: entry.value,
                    icon: Icon(entry.key == 0 ? Icons.move_up_outlined : Icons.draw_outlined),
                  )).toList(),
                  selected: {_tab},
                  onSelectionChanged: (v) => setState(() => _tab = v.first),
                ),
              ),
            Expanded(
              child: _tab == 1 && puedeAutorizar
                  ? _PendingInternalList(items: data.pendientes, onResponder: _responder)
                  : Stack(
                      children: [
                        data.solicitudes.isEmpty
                            ? const EmptyState(
                                text: 'Aun no hay solicitudes de reubicacion.',
                                icon: Icons.move_up_outlined,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
                                itemCount: data.solicitudes.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) => _RelocationCard(
                                  solicitud: data.solicitudes[index],
                                ),
                              ),
                        Positioned(
                          right: 18,
                          bottom: 18,
                          child: FloatingActionButton.extended(
                            onPressed: () => _solicitar(data.catalogos),
                            icon: const Icon(Icons.add_location_alt_outlined),
                            label: const Text('Nueva solicitud'),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _RelocationData {
  const _RelocationData({required this.solicitudes, required this.catalogos, required this.pendientes});
  final List<RelocationRequest> solicitudes;
  final RelocationCatalogs catalogos;
  final List<RelocationRequest> pendientes;
}

class _PendingInternalList extends StatelessWidget {
  const _PendingInternalList({required this.items, required this.onResponder});
  final List<RelocationRequest> items;
  final ValueChanged<RelocationRequest> onResponder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState(text: 'No tienes reubicaciones internas pendientes de autorizar.', icon: Icons.draw_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final s = items[index];
        return InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.maquina, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('${s.origen} → ${s.destino}'),
              const SizedBox(height: 4),
              Text(s.descripcion, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              if (s.evidenciaUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(s.evidenciaUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => onResponder(s),
                  icon: const Icon(Icons.draw_outlined),
                  label: const Text('Firmar y autorizar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RelocationCard extends StatelessWidget {
  const _RelocationCard({required this.solicitud});
  final RelocationRequest solicitud;

  @override
  Widget build(BuildContext context) {
    final estado = solicitud.estado.toLowerCase();
    final color = estado == 'aprobado'
        ? const Color(0xFF1E8E5A)
        : estado == 'rechazado'
            ? const Color(0xFFC0392B)
            : const Color(0xFFB8860B);
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(solicitud.maquina, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
            Chip(backgroundColor: color.withValues(alpha: .14), label: Text(solicitud.estado, style: TextStyle(color: color))),
          ]),
          const SizedBox(height: 6),
          Text('${solicitud.origen} → ${solicitud.destino}'),
          const SizedBox(height: 4),
          Text(solicitud.descripcion, style: Theme.of(context).textTheme.bodySmall),
          if (solicitud.respuesta.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(solicitud.respuesta, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _DecisionDialog extends StatefulWidget {
  const _DecisionDialog({required this.solicitud});
  final RelocationRequest solicitud;
  @override
  State<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<_DecisionDialog> {
  final _observacion = TextEditingController();
  final _firma = SignaturePadController();
  var _aprobar = true;

  @override
  void dispose() { _observacion.dispose(); _firma.dispose(); super.dispose(); }

  Future<void> _confirmar() async {
    if (!_aprobar && _observacion.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Indica el motivo del rechazo.')));
      return;
    }
    final png = await _firma.exportPngBase64();
    if (png == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registra la firma antes de continuar.')));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop({'aprobar': _aprobar, 'firma': png, 'observacion': _observacion.text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Firmar reubicacion interna'),
      content: SizedBox(
        width: 430,
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.solicitud.maquina, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [ButtonSegment(value: true, label: Text('Autorizar')), ButtonSegment(value: false, label: Text('Rechazar'))],
              selected: {_aprobar},
              onSelectionChanged: (v) => setState(() => _aprobar = v.first),
            ),
            const SizedBox(height: 12),
            TextField(controller: _observacion, maxLines: 2, decoration: InputDecoration(labelText: _aprobar ? 'Observacion (opcional)' : 'Motivo del rechazo')),
            const SizedBox(height: 14),
            Text('Firma electronica', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SignaturePad(controller: _firma),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _firma.clear, child: const Text('Borrar firma'))),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _confirmar, child: Text(_aprobar ? 'Autorizar' : 'Rechazar')),
      ],
    );
  }
}
