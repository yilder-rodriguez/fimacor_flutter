import 'package:flutter/material.dart';

import '../theme.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.gradientePrimario,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primario.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.precision_manufacturing_rounded,
            color: Colors.white,
            size: 32,
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
                      fontWeight: FontWeight.w900,
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
