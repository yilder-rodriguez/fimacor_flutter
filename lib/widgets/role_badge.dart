import 'package:flutter/material.dart';

import '../theme.dart';

/// Etiqueta compacta que deja explicito a que rol pertenece la vista
/// actual (por ejemplo "Vista de Tecnico"). Estilo placa/etiqueta
/// tecnica: rectangular con esquina minima y borde solido, no la
/// pastilla completamente redondeada de cualquier app generica.
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
        color: light ? Colors.white.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border(
          left: BorderSide(color: light ? Colors.white : color, width: 3),
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
