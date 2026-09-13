import 'package:flutter/material.dart';

import '../theme.dart';

/// Estado vacio: placa cuadrada (no burbuja circular con degradado) con
/// el icono y un texto que dice que hacer, igual que una senal en un
/// taller en vez de una ilustracion decorativa.
class EmptyState extends StatelessWidget {
  const EmptyState({required this.text, this.icon = Icons.inbox_outlined, super.key});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.superficieAlterna,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.bordePlaca),
              ),
              child: Icon(icon, size: 32, color: AppColors.primarioOscuro),
            ),
            const SizedBox(height: 18),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textoLabel,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
