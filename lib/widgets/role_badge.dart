import 'package:flutter/material.dart';

import '../theme.dart';

/// Etiqueta compacta que deja explicito a que rol pertenece la vista
/// actual (por ejemplo "Vista de Tecnico"). Se usa en la parte
/// superior de las pantallas para que quede claro que cada rol ve
/// solo lo que le corresponde, y no un panel generico compartido.
class RoleBadge extends StatelessWidget {
  const RoleBadge({required this.role, this.light = false, super.key});

  final String? role;

  /// Si es true, usa colores claros (para fondos oscuros como el
  /// header hero o el login).
  final bool light;

  @override
  Widget build(BuildContext context) {
    final rol = (role ?? '').trim();
    if (rol.isEmpty) return const SizedBox.shrink();

    final color = AppColors.paraRol(rol);
    final icon = AppColors.iconoParaRol(rol);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: light ? Colors.white.withValues(alpha: 0.14) : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: light ? Colors.white.withValues(alpha: 0.35) : color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: light ? Colors.white : color),
          const SizedBox(width: 6),
          Text(
            'Vista de $rol',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: light ? Colors.white : color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
