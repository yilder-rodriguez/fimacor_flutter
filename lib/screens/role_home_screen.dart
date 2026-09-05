import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/role_badge.dart';
import 'login_screen.dart';

/// Pantalla que ve un usuario logueado con un rol para el que todavia no
/// hay modulos dedicados en la app movil (Administrador, Aprendiz,
/// Instructor, Logistica, Subdireccion). El login ya funciona igual que en
/// la web para estos roles; los modulos de gestion de cada uno llegan en
/// fases siguientes, y por eso esta pantalla es deliberadamente sencilla:
/// no muestra datos ni acciones de otros roles.
class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({required this.api, super.key});

  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    final rol = api.role ?? '';
    final color = AppColors.paraRol(rol);
    final icon = AppColors.iconoParaRol(rol);

    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: Stack(
        children: [
          Positioned(
            top: -70,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.14),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'FIMACOR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar sesion',
                        onPressed: () async {
                          await api.logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        constraints: const BoxConstraints(maxWidth: 440),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 26,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Icon(icon, color: color, size: 36),
                            ),
                            const SizedBox(height: 18),
                            RoleBadge(role: rol),
                            const SizedBox(height: 14),
                            Text(
                              'Hola, ${rol.isEmpty ? 'usuario' : rol}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF16352D),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tu inicio de sesion funciona igual que en la web. '
                              'Los modulos propios de tu rol (${rol.isEmpty ? 'este rol' : rol}) '
                              'se estan agregando a la app y llegaran en una proxima '
                              'actualizacion. Aqui solo veras informacion relacionada '
                              'con tu rol, nunca la de otros roles del sistema.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textoLabel,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
