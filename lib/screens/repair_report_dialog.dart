import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/repair_pending.dart';

/// Resultado del formulario: observacion del tecnico + fotos de evidencia.
class RepairReportResult {
  RepairReportResult({required this.observation, required this.photos});

  final String observation;
  final List<File> photos;
}

/// Formulario de reparacion del tecnico: describe que arreglo, que
/// repuestos uso y adjunta evidencia fotografica (obligatoria). Es el
/// equivalente movil del formulario "Confirmar reparacion" que el
/// tecnico llena en la web (Historial_mantenimiento.jsp), pero con foto.
class RepairReportDialog extends StatefulWidget {
  const RepairReportDialog({required this.pending, super.key});

  final RepairPending pending;

  @override
  State<RepairReportDialog> createState() => _RepairReportDialogState();
}

class _RepairReportDialogState extends State<RepairReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _observation = TextEditingController();
  final _picker = ImagePicker();
  final List<File> _photos = [];
  bool _enviando = false;

  @override
  void dispose() {
    _observation.dispose();
    super.dispose();
  }

  Future<void> _agregarFoto(ImageSource source) async {
    try {
      final foto = await _picker.pickImage(source: source, imageQuality: 80);
      if (foto == null) return;
      setState(() => _photos.add(File(foto.path)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener la foto: $error')),
      );
    }
  }

  void _quitarFoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.pending;
    return AlertDialog(
      title: const Text('Reportar arreglo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pending.machineCode.isEmpty
                    ? pending.description
                    : pending.machineCode,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (pending.tasks.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Tareas: ${pending.tasks}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _observation,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Describe que arreglaste, repuestos usados y prueba realizada',
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Describe el arreglo realizado.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Evidencia fotografica (obligatoria)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _photos.length; i++)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _photos[i],
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, size: 20),
                            onPressed: () => _quitarFoto(i),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  OutlinedButton.icon(
                    onPressed: () => _agregarFoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Camara'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _agregarFoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeria'),
                  ),
                ],
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
          onPressed: _enviando
              ? null
              : () {
                  if (!_formKey.currentState!.validate()) return;
                  if (_photos.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adjunta al menos una foto de evidencia.'),
                      ),
                    );
                    return;
                  }
                  setState(() => _enviando = true);
                  Navigator.of(context).pop(
                    RepairReportResult(
                      observation: _observation.text.trim(),
                      photos: List.of(_photos),
                    ),
                  );
                },
          child: Text(_enviando ? 'Enviando...' : 'Guardar reparacion'),
        ),
      ],
    );
  }
}
