import 'package:flutter/material.dart';

import '../../models/admin_role_permiso.dart';
import '../../services/api_client.dart';
import '../../theme.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/future_panel.dart';
import '../../widgets/info_card.dart';
import 'admin_permission_form_dialog.dart';
import 'admin_role_form_dialog.dart';

/// Modulo "Roles y permisos" del panel de Administrador. Equivalente
/// movil de Roles.jsp + Permisos.jsp: dos pestanas, una para administrar
/// roles (con sus permisos) y otra para el catalogo de permisos.
class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  late Future<_RolesData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RolesData> _load() async {
    final results = await Future.wait([
      widget.api.adminRolesConPermisos(),
      widget.api.adminPermisos(),
    ]);
    return _RolesData(
      roles: results[0] as List<AdminRolPermisos>,
      permisos: results[1] as List<AdminPermiso>,
    );
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _crearOEditarRol(List<AdminPermiso> permisos, {AdminRolPermisos? rol}) async {
    final valores = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AdminRoleFormDialog(permisosDisponibles: permisos, rol: rol),
    );
    if (valores == null) return;

    try {
      await widget.api.adminSaveRole(
        idRolObjetivo: rol?.idRol,
        descripcion: valores['descripcion'] as String,
        permisos: valores['permisos'] as Set<int>,
      );
      if (!mounted) return;
      showAppSnack(context, rol == null ? 'Rol creado.' : 'Rol actualizado.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  Future<void> _eliminarRol(AdminRolPermisos rol) async {
    if (rol.rolTotal) {
      showAppSnack(context, 'No puedes eliminar un rol con permisos totales.');
      return;
    }
    if (rol.totalUsuarios > 0) {
      showAppSnack(
        context,
        'Hay ${rol.totalUsuarios} usuario(s) con este rol; reasignalos antes de eliminarlo.',
      );
      return;
    }
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar rol'),
        content: Text('¿Eliminar el rol "${rol.nombre}"?'),
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
      await widget.api.adminDeleteRole(rol.idRol);
      if (!mounted) return;
      showAppSnack(context, 'Rol eliminado.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  Future<void> _crearOEditarPermiso({AdminPermiso? permiso}) async {
    final valores = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AdminPermissionFormDialog(permiso: permiso),
    );
    if (valores == null) return;

    try {
      await widget.api.adminSavePermission(
        idPermisoObjetivo: permiso?.idPermiso,
        codigo: valores['codigo'] as String,
        descripcion: valores['descripcion'] as String,
      );
      if (!mounted) return;
      showAppSnack(context, permiso == null ? 'Permiso creado.' : 'Permiso actualizado.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  Future<void> _eliminarPermiso(AdminPermiso permiso) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar permiso'),
        content: Text(
          '¿Eliminar "${permiso.codigo}"? Se quitara de todos los roles que lo tengan asignado.',
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
      await widget.api.adminDeletePermission(permiso.idPermiso);
      if (!mounted) return;
      showAppSnack(context, 'Permiso eliminado.');
      _refresh();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Roles y permisos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Roles'),
              Tab(text: 'Catalogo de permisos'),
            ],
          ),
        ),
        body: FuturePanel<_RolesData>(
          mensajeCarga: 'Cargando roles y permisos...',
          future: _future,
          onRefresh: _refresh,
          builder: (context, data) {
            return TabBarView(
              children: [
                _RolesTab(
                  roles: data.roles,
                  onNuevo: () => _crearOEditarRol(data.permisos),
                  onEditar: (rol) => _crearOEditarRol(data.permisos, rol: rol),
                  onEliminar: _eliminarRol,
                ),
                _PermisosTab(
                  permisos: data.permisos,
                  onNuevo: () => _crearOEditarPermiso(),
                  onEditar: (p) => _crearOEditarPermiso(permiso: p),
                  onEliminar: _eliminarPermiso,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RolesData {
  const _RolesData({required this.roles, required this.permisos});
  final List<AdminRolPermisos> roles;
  final List<AdminPermiso> permisos;
}

class _RolesTab extends StatelessWidget {
  const _RolesTab({
    required this.roles,
    required this.onNuevo,
    required this.onEditar,
    required this.onEliminar,
  });

  final List<AdminRolPermisos> roles;
  final VoidCallback onNuevo;
  final void Function(AdminRolPermisos rol) onEditar;
  final void Function(AdminRolPermisos rol) onEliminar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        roles.isEmpty
            ? const EmptyState(text: 'Aun no hay roles creados.', icon: Icons.badge_outlined)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
                itemCount: roles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rol = roles[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: InfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.rolAdministrador.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings_outlined,
                                    color: AppColors.rolAdministrador,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    rol.nombre,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  avatar: const Icon(Icons.people_outline, size: 16),
                                  label: Text('${rol.totalUsuarios} usuario(s)'),
                                ),
                                if (rol.rolTotal)
                                  const Chip(
                                    backgroundColor: Color(0xFFE3F6EC),
                                    avatar: Icon(Icons.verified_rounded, size: 16),
                                    label: Text('Permisos totales'),
                                  )
                                else
                                  Chip(
                                    avatar: const Icon(Icons.key_outlined, size: 16),
                                    label: Text('${rol.permisos.length} permiso(s)'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => onEditar(rol),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Editar'),
                                ),
                                const SizedBox(width: 4),
                                TextButton.icon(
                                  onPressed: rol.rolTotal ? null : () => onEliminar(rol),
                                  icon: const Icon(Icons.delete_outline_rounded),
                                  label: const Text('Eliminar'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFC0392B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton.extended(
            onPressed: onNuevo,
            icon: const Icon(Icons.add_moderator_outlined),
            label: const Text('Nuevo rol'),
          ),
        ),
      ],
    );
  }
}

class _PermisosTab extends StatelessWidget {
  const _PermisosTab({
    required this.permisos,
    required this.onNuevo,
    required this.onEditar,
    required this.onEliminar,
  });

  final List<AdminPermiso> permisos;
  final VoidCallback onNuevo;
  final void Function(AdminPermiso permiso) onEditar;
  final void Function(AdminPermiso permiso) onEliminar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        permisos.isEmpty
            ? const EmptyState(
                text: 'Aun no hay permisos en el catalogo.',
                icon: Icons.key_off_outlined,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
                itemCount: permisos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final permiso = permisos[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: InfoCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    permiso.codigo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    permiso.descripcion,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              onPressed: () => onEditar(permiso),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              onPressed: () => onEliminar(permiso),
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: const Color(0xFFC0392B),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton.extended(
            onPressed: onNuevo,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo permiso'),
          ),
        ),
      ],
    );
  }
}
