import 'package:flutter/material.dart';

import '../theme.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.verdeClaroChip,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.precision_manufacturing_rounded,
            color: AppColors.primario,
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
