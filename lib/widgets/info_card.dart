import 'package:flutter/material.dart';

import '../theme.dart';

/// Tarjeta base usada en toda la app para agrupar contenido. Ahora con
/// sombra mas suave, borde sutil y esquinas mas redondeadas para un
/// look mas moderno.
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFEDF2EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0B1C22),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
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
