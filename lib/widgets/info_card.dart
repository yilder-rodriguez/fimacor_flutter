import 'package:flutter/material.dart';

import '../theme.dart';

/// Tarjeta base de FIMACOR: estilo "ficha de taller" en vez del kit de
/// tarjeta redondeada con sombra suave que usa cualquier app generica.
/// Esquinas casi rectas, borde solido de acero, sin sombra, y una barra
/// de color solida a la izquierda que puede codificar estado o rol
/// (como la pestana de una carpeta de orden de trabajo).
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.accentColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Color de la barra izquierda. Si es null, usa un acero neutro (sin
  /// significado de estado); pasar un color de estado/rol le da a la
  /// ficha una funcion informativa, no decorativa.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final barra = accentColor ?? AppColors.acero.withValues(alpha: 0.35);

    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.bordePlaca),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: barra),
            Expanded(child: Padding(padding: padding, child: child)),
          ],
        ),
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
