import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../theme.dart';
import 'admin_catalog_items_screen.dart';
import 'catalog_type_config.dart';

/// Modulo "Catalogos" del panel de Administrador. Equivalente movil de
/// Configuracion.jsp: un indice con los 7 catalogos que alimentan a
/// Maquinas y Mantenimiento.
class AdminCatalogsScreen extends StatelessWidget {
  const AdminCatalogsScreen({required this.api, super.key});

  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogos')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: GridView.builder(
              padding: const EdgeInsets.all(18),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              itemCount: kCatalogTypes.length,
              itemBuilder: (context, index) {
                final config = kCatalogTypes[index];
                return _CatalogTile(
                  config: config,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdminCatalogItemsScreen(api: api, config: config),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.config, required this.onTap});

  final CatalogTypeConfig config;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.rolAdministrador;
    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const Color(0xFFEDF2EF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(config.icon, color: color),
              ),
              const Spacer(),
              Text(
                config.titulo,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
