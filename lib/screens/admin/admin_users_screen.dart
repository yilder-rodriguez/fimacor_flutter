import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/future_panel.dart';
import '../../widgets/info_card.dart';
import 'admin_user_form_dialog.dart';

/// Modulo "Usuarios" del panel de Administrador. Equivalente movil de
/// Tabla_usuario.jsp: listar, crear, editar, activar/desactivar y
/// eliminar usuarios de cualquier rol.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<_UsersData> _future;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<_UsersData> _load() async {
    final results = await Future.wait([
      widget.api.adminUsers(),
      widget.api.adminRoles(),
    ]);
    return _UsersData(
      usuarios: results[0] as List<AdminUser>,
      roles: results[1] as List<AdminRole>,
    );
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _crearOEditar(List<AdminRole> roles, {AdminUser? usuario}) async {
    if (roles.isEmpty) {
      showAppSnack(context, 'No hay roles configurados en el sistema.');
      return;
    }
    final valores = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AdminUserFormDialog(roles: roles, usuario: usuario),
    );
    if (valores == null) return;

    try {
      await widget.api.adminSaveUser(
        idUsuarioObjetivo: usuario?.idUsuario,
        nombre: valores['nombre'] as String,
        apellido: valores['apellido'] as String,
        documento: valores['documento'] as String,
        telefono: valores['telefono'] as String,
        correo: valores['correo'] as String,
        contrasena: valores['contrasena'] as String,
        tipoDoc: valores['tipoDoc'] as String,
        idRol: valores['idRol'] as int,
        activo: valores['activo'] as bool,
      );
      if (!mounted) return;
      showAppSnack(context, usuario == null ? 'Usuario creado.' : 'Usuario actualizado.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  Future<void> _cambiarEstado(AdminUser usuario) async {
    final nuevoEstado = !usuario.activo;
    try {
      await widget.api.adminSetUserStatus(
        idUsuarioObjetivo: usuario.idUsuario,
        activo: nuevoEstado,
      );
      if (!mounted) return;
      showAppSnack(
        context,
        nuevoEstado ? 'Usuario activado.' : 'Usuario desactivado.',
      );
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  Future<void> _eliminar(AdminUser usuario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Eliminar a ${usuario.nombreCompleto}? Esta accion no se puede deshacer '
          'y tambien borra su historial de mantenimiento asociado.',
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
      await widget.api.adminDeleteUser(usuario.idUsuario);
      if (!mounted) return;
      showAppSnack(context, 'Usuario eliminado.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: FuturePanel<_UsersData>(
        mensajeCarga: 'Cargando usuarios...',
        future: _future,
        onRefresh: _refresh,
        builder: (context, data) {
          final q = _query.trim().toLowerCase();
          final filtrados = data.usuarios.where((u) {
            if (q.isEmpty) return true;
            return u.nombreCompleto.toLowerCase().contains(q) ||
                u.correo.toLowerCase().contains(q) ||
                u.documento.toLowerCase().contains(q) ||
                u.rol.toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: TextField(
                      controller: _search,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre, correo, documento o rol',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => setState(() {
                                  _search.clear();
                                  _query = '';
                                }),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Row(
                      children: [
                        Text(
                          '${filtrados.length} de ${data.usuarios.length} usuarios',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filtrados.isEmpty
                    ? const EmptyState(
                        text: 'No se encontraron usuarios con ese criterio.',
                        icon: Icons.person_search_rounded,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(18),
                        itemCount: filtrados.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final usuario = filtrados[index];
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: _UserCard(
                                usuario: usuario,
                                esUsuarioActual: usuario.idUsuario == widget.api.userId,
                                onEditar: () => _crearOEditar(data.roles, usuario: usuario),
                                onCambiarEstado: () => _cambiarEstado(usuario),
                                onEliminar: () => _eliminar(usuario),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<_UsersData>(
        future: _future,
        builder: (context, snapshot) {
          final roles = snapshot.data?.roles ?? const <AdminRole>[];
          return FloatingActionButton.extended(
            onPressed: () => _crearOEditar(roles),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Nuevo usuario'),
          );
        },
      ),
    );
  }
}

class _UsersData {
  const _UsersData({required this.usuarios, required this.roles});
  final List<AdminUser> usuarios;
  final List<AdminRole> roles;
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.usuario,
    required this.esUsuarioActual,
    required this.onEditar,
    required this.onCambiarEstado,
    required this.onEliminar,
  });

  final AdminUser usuario;
  final bool esUsuarioActual;
  final VoidCallback onEditar;
  final VoidCallback onCambiarEstado;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.paraRol(usuario.rol);
    final icon = AppColors.iconoParaRol(usuario.rol);

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nombreCompleto,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usuario.correo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: usuario.activo,
                activeThumbColor: AppColors.primario,
                onChanged: esUsuarioActual && usuario.activo
                    ? null
                    : (_) => onCambiarEstado(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(avatar: Icon(icon, size: 16, color: color), label: Text(usuario.rol)),
              Chip(
                avatar: const Icon(Icons.badge_outlined, size: 16),
                label: Text(usuario.documento),
              ),
              if (usuario.telefono.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.call_outlined, size: 16),
                  label: Text(usuario.telefono),
                ),
              Chip(
                backgroundColor: usuario.activo
                    ? AppColors.verdeClaroChip
                    : const Color(0xFFFFE9E0),
                label: Text(usuario.activo ? 'Activo' : 'Inactivo'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: esUsuarioActual ? null : onEliminar,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFC0392B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
