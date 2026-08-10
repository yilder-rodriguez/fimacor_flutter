import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme.dart';
import 'login_screen.dart';

/// Pantalla que ve un usuario logueado con un rol para el que todavia no
/// hay modulos dedicados en la app movil (Administrador, Aprendiz,
/// Instructor, Logistica, Subdireccion). El login ya funciona igual que en
/// la web para estos roles; los modulos de gestion llegan en fases
/// siguientes.
class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({required this.api, super.key});

  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoOscuro,
        foregroundColor: AppColors.textoClaro,
        elevation: 0,
        title: const Text('FIMACOR'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(28),
            constraints: const BoxConstraints(maxWidth: 440),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primario,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hola, ${api.role ?? ''}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF16352D),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Tu inicio de sesion funciona igual que en la web. '
                  'Los modulos de gestion para tu rol se estan agregando '
                  'a la app y llegaran en una proxima actualizacion.',
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
    );
  }
}
