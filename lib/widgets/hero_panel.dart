import 'package:flutter/material.dart';

import '../theme.dart';
import 'role_badge.dart';

/// Encabezado hero de las pantallas principales, con degradado de
/// marca, formas decorativas y la etiqueta de rol para dejar claro de
/// quien es la vista.
class HeroPanel extends StatelessWidget {
  const HeroPanel({
    required this.title,
    required this.subtitle,
    required this.action,
    this.role,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget action;
  final String? role;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(gradient: AppColors.gradienteOscuro),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.acento.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -46,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (role != null) ...[
                  RoleBadge(role: role, light: true),
                  const SizedBox(height: 12),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFFCFE3DA), height: 1.35),
                ),
                const SizedBox(height: 18),
                action,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
