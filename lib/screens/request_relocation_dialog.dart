import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/relocation.dart';

/// Formulario de solicitud de reubicacion (equivalente movil de
/// Reubicacion_maquina.jsp). La evidencia fotografica es obligatoria.
class RequestRelocationDialog extends StatefulWidget {
  const RequestRelocationDialog({
    required this.catalogos,
    this.maquinaPreseleccionada,
    super.key,
  });

  final RelocationCatalogs catalogos;

  /// Si se abre desde la ficha de una maquina especifica, viene
  /// preseleccionada y el campo queda bloqueado.
  final int? maquinaPreseleccionada;

  @override
  State<RequestRelocationDialog> createState() => _RequestRelocationDialogState();
}

class _RequestRelocationDialogState extends State<RequestRelocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _origen = TextEditingController();
  final _destino = TextEditingController();
  final _areaDestino = TextEditingController();
  final _descripcion = TextEditingController();
  final _observacion = TextEditingController();

  int? _idMaquina;
  int? _idAmbienteDestino;
  int? _idSedeDestino;
  var _tipoTraslado = 'Interno';
  File? _evidencia;

  @override
  void initState() {
    super.initState();
    _idMaquina = widget.maquinaPreseleccionada;
  }

  @override
  void dispose() {
    _origen.dispose();
    _destino.dispose();
    _areaDestino.dispose();
    _descripcion.dispose();
    _observacion.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto(ImageSource source) async {
    try {
      final foto = await _picker.pickImage(source: source, imageQuality: 80);
      if (foto == null) return;
      setState(() => _evidencia = File(foto.path));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo obtener la foto: $error')));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_idMaquina == null || _idAmbienteDestino == null) return;
    if (_evidencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adjunta una foto de evidencia (obligatoria).')),
      );
      return;
    }
    Navigator.of(context).pop({
      'idMaquina': _idMaquina,
      'tipoTraslado': _tipoTraslado,
      'origen': _origen.text.trim(),
      'destino': _destino.text.trim(),
      'idAmbienteDestino': _idAmbienteDestino,
      'idSedeDestino': _idSedeDestino,
      'areaDestino': _areaDestino.text.trim(),
      'descripcion': _descripcion.text.trim(),
      'observacion': _observacion.text.trim(),
      'evidencia': _evidencia,
    });
  }

  @override
  Widget build(BuildContext context) {
    final esExterno = _tipoTraslado == 'Externo';
    return AlertDialog(
      title: const Text('Solicitar reubicacion'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _idMaquina,
                  decoration: const InputDecoration(labelText: 'Maquina'),
                  items: widget.catalogos.maquinas
                      .map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)))
                      .toList(),
                  onChanged: widget.maquinaPreseleccionada != null
                      ? null
                      : (v) => setState(() => _idMaquina = v),
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Interno', label: Text('Traslado interno')),
                    ButtonSegment(value: 'Externo', label: Text('Traslado externo')),
                  ],
                  selected: {_tipoTraslado},
                  onSelectionChanged: (v) => setState(() {
                    _tipoTraslado = v.first;
                    if (!esExterno) _idSedeDestino = null;
                  }),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _origen,
                  decoration: const InputDecoration(labelText: 'Ambiente/lugar de origen'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destino,
                  decoration: const InputDecoration(labelText: 'Descripcion del destino'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _idAmbienteDestino,
                  decoration: const InputDecoration(labelText: 'Ambiente destino'),
                  items: widget.catalogos.ambientes
                      .map((a) => DropdownMenuItem(value: a.id, child: Text(a.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _idAmbienteDestino = v),
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                if (esExterno) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _idSedeDestino,
                    decoration: const InputDecoration(labelText: 'Sede destino'),
                    items: widget.catalogos.sedes
                        .map((s) => DropdownMenuItem(value: s.id, child: Text(s.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _idSedeDestino = v),
                    validator: (v) => v == null ? 'Requerido para traslado externo' : null,
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Los traslados internos siempre van a la sede Complejo Sur.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF60746E)),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _areaDestino,
                  decoration: const InputDecoration(labelText: 'Area destino'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcion,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Motivo de la reubicacion'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacion,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Observaciones (opcional)'),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Evidencia fotografica (obligatoria)',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                const SizedBox(height: 8),
                if (_evidencia != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_evidencia!, height: 140, fit: BoxFit.cover, width: double.infinity),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _elegirFoto(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Camara'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _elegirFoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galeria'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Enviar solicitud'),
        ),
      ],
    );
  }
}
