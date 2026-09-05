import 'package:flutter/material.dart';

import '../../models/admin_role_permiso.dart';
import '../../theme.dart';

/// Formulario de alta/edicion de rol: nombre + checklist de permisos.
/// Si el rol es "total" (Administrador) no se editan permisos porque
/// siempre los tiene todos (misma regla que AccesoPermiso.esRolTotal en
/// el servidor).
class AdminRoleFormDialog extends StatefulWidget {
  const AdminRoleFormDialog({
    required this.permisosDisponibles,
    this.rol,
    super.key,
  });

  final List<AdminPermiso> permisosDisponibles;
  final AdminRolPermisos? rol;

  @override
  State<AdminRoleFormDialog> createState() => _AdminRoleFormDialogState();
}

class _AdminRoleFormDialogState extends State<AdminRoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late Set<int> _seleccionados;

  bool get _esRolTotal => widget.rol?.rolTotal ?? false;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.rol?.nombre ?? '');
    _seleccionados = {...(widget.rol?.permisos ?? const <int>{})};
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'descripcion': _nombre.text.trim(),
      'permisos': _seleccionados,
    });
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.rol == null;
    return AlertDialog(
      title: Text(esNuevo ? 'Nuevo rol' : 'Editar rol'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre del rol'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Permisos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 4),
              if (_esRolTotal)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.verdeClaroChip,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Text(
                    'Este rol tiene permisos totales: siempre puede hacer '
                    'todo en el sistema, sin importar esta lista.',
                  ),
                )
              else if (widget.permisosDisponibles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Aun no hay permisos creados en el catalogo.'),
                )
              else
                SizedBox(
                  height: 260,
                  child: ListView(
                    shrinkWrap: true,
                    children: widget.permisosDisponibles.map((p) {
                      final marcado = _seleccionados.contains(p.idPermiso);
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primario,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(p.codigo),
                        subtitle: Text(p.descripcion),
                        value: marcado,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _seleccionados.add(p.idPermiso);
                          } else {
                            _seleccionados.remove(p.idPermiso);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ),
            ],
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
          child: Text(esNuevo ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}
