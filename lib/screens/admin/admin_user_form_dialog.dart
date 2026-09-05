import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import '../../theme.dart';

/// Formulario de alta/edicion de usuario. Devuelve un mapa con los
/// valores capturados (o null si se cancela) para que AdminUsersScreen
/// haga la llamada real a la API y maneje los errores del servidor.
class AdminUserFormDialog extends StatefulWidget {
  const AdminUserFormDialog({
    required this.roles,
    this.usuario,
    super.key,
  });

  final List<AdminRole> roles;

  /// Null cuando se esta creando un usuario nuevo.
  final AdminUser? usuario;

  @override
  State<AdminUserFormDialog> createState() => _AdminUserFormDialogState();
}

class _AdminUserFormDialogState extends State<AdminUserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _documento;
  late final TextEditingController _telefono;
  late final TextEditingController _correo;
  final _contrasena = TextEditingController();
  String _tipoDoc = 'CC';
  int? _idRol;
  var _activo = true;
  var _obscure = true;

  bool get _esNuevo => widget.usuario == null;

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    _nombre = TextEditingController(text: u?.nombre ?? '');
    _apellido = TextEditingController(text: u?.apellido ?? '');
    _documento = TextEditingController(text: u?.documento ?? '');
    _telefono = TextEditingController(text: u?.telefono ?? '');
    _correo = TextEditingController(text: u?.correo ?? '');
    _activo = u?.activo ?? true;
    _idRol = u?.idRol ?? (widget.roles.isNotEmpty ? widget.roles.first.idRol : null);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _documento.dispose();
    _telefono.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_idRol == null) return;
    Navigator.of(context).pop({
      'nombre': _nombre.text.trim(),
      'apellido': _apellido.text.trim(),
      'documento': _documento.text.trim(),
      'telefono': _telefono.text.trim(),
      'correo': _correo.text.trim(),
      'contrasena': _contrasena.text,
      'tipoDoc': _tipoDoc,
      'idRol': _idRol,
      'activo': _activo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_esNuevo ? 'Nuevo usuario' : 'Editar usuario'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nombre,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _apellido,
                        decoration: const InputDecoration(labelText: 'Apellido'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: DropdownButtonFormField<String>(
                        initialValue: _tipoDoc,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: const [
                          DropdownMenuItem(value: 'CC', child: Text('CC')),
                          DropdownMenuItem(value: 'TI', child: Text('TI')),
                          DropdownMenuItem(value: 'CE', child: Text('CE')),
                        ],
                        onChanged: (v) => setState(() => _tipoDoc = v ?? 'CC'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _documento,
                        decoration: const InputDecoration(labelText: 'Documento'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefono,
                  decoration: const InputDecoration(labelText: 'Telefono'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _correo,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Correo invalido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contrasena,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: _esNuevo
                        ? 'Contrasena'
                        : 'Nueva contrasena (opcional)',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (_esNuevo && (v == null || v.isEmpty)) {
                      return 'Requerida para un usuario nuevo';
                    }
                    if (v != null && v.isNotEmpty && v.length < 4) {
                      return 'Minimo 4 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _idRol,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: widget.roles
                      .map((r) => DropdownMenuItem(value: r.idRol, child: Text(r.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _idRol = v),
                  validator: (v) => v == null ? 'Selecciona un rol' : null,
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primario,
                  title: const Text('Usuario activo'),
                  value: _activo,
                  onChanged: (v) => setState(() => _activo = v),
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
          child: Text(_esNuevo ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}
