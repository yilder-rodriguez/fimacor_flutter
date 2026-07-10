import 'package:flutter/material.dart';

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
            color: const Color(0xFFE3F5EF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.account_circle_outlined,
            color: Color(0xFF10875F),
            size: 34,
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
                    ),
              ),
              Text(
                'Panel de acceso',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF667B75),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
