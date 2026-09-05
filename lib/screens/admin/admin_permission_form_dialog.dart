import 'package:flutter/material.dart';

import '../../models/admin_role_permiso.dart';

/// Formulario de alta/edicion de un permiso del catalogo (codigo +
/// descripcion). Devuelve un mapa con los valores o null si se cancela.
class AdminPermissionFormDialog extends StatefulWidget {
  const AdminPermissionFormDialog({this.permiso, super.key});

  final AdminPermiso? permiso;

  @override
  State<AdminPermissionFormDialog> createState() => _AdminPermissionFormDialogState();
}

class _AdminPermissionFormDialogState extends State<AdminPermissionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigo;
  late final TextEditingController _descripcion;

  @override
  void initState() {
    super.initState();
    _codigo = TextEditingController(text: widget.permiso?.codigo ?? '');
    _descripcion = TextEditingController(text: widget.permiso?.descripcion ?? '');
  }

  @override
  void dispose() {
    _codigo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'codigo': _codigo.text.trim(),
      'descripcion': _descripcion.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.permiso == null;
    return AlertDialog(
      title: Text(esNuevo ? 'Nuevo permiso' : 'Editar permiso'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _codigo,
              decoration: const InputDecoration(
                labelText: 'Codigo',
                hintText: 'ej. usuarios.editar',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcion,
              decoration: const InputDecoration(labelText: 'Descripcion'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
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
          onPressed: _submit,
          child: Text(esNuevo ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}
