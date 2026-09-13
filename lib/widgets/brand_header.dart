import 'package:flutter/material.dart';

import '../theme.dart';

/// Encabezado de marca: usa el emblema real de FIMACOR (recortado del
/// logo del proyecto) sobre una placa tinta, en vez de un icono
/// generico de Material dentro de una caja con degradado.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.tinta,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.primarioClaro, width: 2),
          ),
          child: Image.asset(
            'assets/images/fimacor_icon_foreground.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FIMACOR',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primarioOscuro,
                      letterSpacing: 0.3,
                    ),
              ),
              Text(
                'Centro de Manufactura Textil y del Cuero · SENA',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textoLabel,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
