import 'package:flutter/material.dart';

import '../models/machine.dart';

class ReportFailureDialog extends StatefulWidget {
  const ReportFailureDialog({required this.machine, super.key});

  final Machine machine;

  @override
  State<ReportFailureDialog> createState() => _ReportFailureDialogState();
}

class _ReportFailureDialogState extends State<ReportFailureDialog> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reportar falla'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.machine.code.isEmpty
                  ? widget.machine.description
                  : widget.machine.code,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Descripcion'),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Describe la falla encontrada.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_description.text.trim());
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
