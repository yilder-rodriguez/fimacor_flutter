import 'package:flutter/material.dart';

import '../models/relocation.dart';
import '../services/api_client.dart';
import '../widgets/app_snack.dart';
import '../widgets/empty_state.dart';
import '../widgets/future_panel.dart';
import '../widgets/info_card.dart';
import '../widgets/signature_pad.dart';

/// Bandeja de Subdireccion: solicitudes de reubicacion pendientes de
/// firma, con aprobar/rechazar. Equivalente movil de la autorizacion que
/// hoy vive en Menu.jsp (firma manuscrita + evidencia obligatoria).
class SubdireccionRelocationsScreen extends StatefulWidget {
  const SubdireccionRelocationsScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<SubdireccionRelocationsScreen> createState() =>
      _SubdireccionRelocationsScreenState();
}

class _SubdireccionRelocationsScreenState
    extends State<SubdireccionRelocationsScreen> {
  late Future<List<RelocationRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.pendingRelocationRequests();
  }

  void _refresh() =>
      setState(() => _future = widget.api.pendingRelocationRequests());

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
      showAppSnack(
        context,
        resultado['aprobar'] as bool ? 'Reubicacion aprobada.' : 'Reubicacion rechazada.',
      );
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FuturePanel<List<RelocationRequest>>(
      mensajeCarga: 'Cargando solicitudes pendientes...',
      future: _future,
      onRefresh: _refresh,
      builder: (context, solicitudes) {
        if (solicitudes.isEmpty) {
          return const EmptyState(
            text: 'No hay solicitudes de reubicacion pendientes.',
            icon: Icons.fact_check_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: solicitudes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final solicitud = solicitudes[index];
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
                      Chip(label: Text(solicitud.tipoTraslado)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${solicitud.origen} \u2192 ${solicitud.destino} (${solicitud.areaDestino})'),
                  const SizedBox(height: 4),
                  Text(solicitud.descripcion, style: Theme.of(context).textTheme.bodySmall),
                  if (solicitud.observacion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Observacion: ${solicitud.observacion}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  if (solicitud.evidenciaUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        solicitud.evidenciaUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Esta solicitud no tiene evidencia adjunta: no se puede aprobar.',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => _responder(solicitud),
                      icon: const Icon(Icons.draw_outlined),
                      label: const Text('Firmar decision'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
  final _firmaController = SignaturePadController();
  var _aprobar = true;
  var _enviando = false;

  @override
  void dispose() {
    _observacion.dispose();
    _firmaController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!_aprobar && _observacion.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica el motivo del rechazo.')),
      );
      return;
    }
    if (_aprobar && widget.solicitud.evidenciaUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede aprobar: falta evidencia.')),
      );
      return;
    }
    setState(() => _enviando = true);
    final firma = await _firmaController.exportPngBase64();
    if (firma == null) {
      setState(() => _enviando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firma en el recuadro antes de continuar.')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop({
      'aprobar': _aprobar,
      'firma': firma,
      'observacion': _observacion.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Firmar decision'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.solicitud.maquina,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Aprobar')),
                  ButtonSegment(value: false, label: Text('Rechazar')),
                ],
                selected: {_aprobar},
                onSelectionChanged: (v) => setState(() => _aprobar = v.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _observacion,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: _aprobar ? 'Observacion (opcional)' : 'Motivo del rechazo',
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Firma electronica', style: Theme.of(context).textTheme.titleSmall),
              ),
              const SizedBox(height: 8),
              SignaturePad(controller: _firmaController),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _firmaController.clear,
                  child: const Text('Borrar firma'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviando ? null : _confirmar,
          child: _enviando
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_aprobar ? 'Aprobar' : 'Rechazar'),
        ),
      ],
    );
  }
}
