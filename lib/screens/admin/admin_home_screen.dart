import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../theme.dart';
import '../../widgets/app_snack.dart';
import '../login_screen.dart';
import 'admin_roles_screen.dart';
import 'admin_users_screen.dart';

/// Panel de inicio del rol Administrador. Cada tarjeta es un modulo de
/// gestion (equivalente movil de una seccion del menu web). Por ahora
/// solo "Usuarios" tiene pantalla propia; el resto de modulos con mas
/// permisos (roles/permisos, maquinas, mantenimiento, catalogos,
/// reportes) se agregan en fases siguientes y se muestran como
/// "Proximamente" para que quede claro que el resto del panel llega
/// despues, sin bloquear lo que ya esta listo.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({required this.api, super.key});

  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    final modulos = <_AdminModule>[
      _AdminModule(
        titulo: 'Usuarios',
        subtitulo: 'Crear, editar, activar y eliminar usuarios',
        icon: Icons.group_rounded,
        disponible: true,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AdminUsersScreen(api: api)),
        ),
      ),
      _AdminModule(
        titulo: 'Roles y permisos',
        subtitulo: 'Definir que puede hacer cada rol',
        icon: Icons.admin_panel_settings_outlined,
        disponible: true,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AdminRolesScreen(api: api)),
        ),
      ),
      _AdminModule(
        titulo: 'Maquinas',
        subtitulo: 'Ficha tecnica y asignacion a cuentadantes',
        icon: Icons.precision_manufacturing_outlined,
        disponible: false,
      ),
      _AdminModule(
        titulo: 'Mantenimiento',
        subtitulo: 'Programacion y seguimiento de mantenimientos',
        icon: Icons.build_outlined,
        disponible: false,
      ),
      _AdminModule(
        titulo: 'Catalogos',
        subtitulo: 'Sedes, areas, ambientes, marcas y modelos',
        icon: Icons.category_outlined,
        disponible: false,
      ),
      _AdminModule(
        titulo: 'Reportes',
        subtitulo: 'Indicadores generales del sistema',
        icon: Icons.bar_chart_rounded,
        disponible: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.fondoApp,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('FIMACOR'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                api.role ?? 'Administrador',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () async {
              await api.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: GridView.builder(
              padding: const EdgeInsets.all(18),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemCount: modulos.length,
              itemBuilder: (context, index) {
                final modulo = modulos[index];
                return _ModuleCard(
                  modulo: modulo,
                  onTapNoDisponible: () => showAppSnack(
                    context,
                    '${modulo.titulo}: este modulo llega en una proxima actualizacion.',
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminModule {
  const _AdminModule({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.disponible,
    this.onTap,
  });

  final String titulo;
  final String subtitulo;
  final IconData icon;
  final bool disponible;
  final VoidCallback? onTap;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.modulo, required this.onTapNoDisponible});

  final _AdminModule modulo;
  final VoidCallback onTapNoDisponible;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.rolAdministrador;

    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: modulo.disponible ? modulo.onTap : onTapNoDisponible,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const Color(0xFFEDF2EF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(modulo.icon, color: color),
              ),
              const Spacer(),
              Text(
                modulo.titulo,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                modulo.subtitulo,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!modulo.disponible) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Proximamente',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B4FBB),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
