import 'package:flutter/material.dart';

import '../theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.verdeClaroChip,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 30,
                color: AppColors.primario,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textoLabel),
            ),
          ],
        ),
      ),
    );
  }
}
