import 'package:flutter/material.dart';

import '../models/maintenance_item.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/future_panel.dart';
import '../widgets/info_card.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  late Future<List<MaintenanceItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.maintenance();
  }

  @override
  Widget build(BuildContext context) {
    return FuturePanel<List<MaintenanceItem>>(
      mensajeCarga: 'Cargando mantenimientos...',
      future: _future,
      onRefresh: () => setState(() => _future = widget.api.maintenance()),
      builder: (context, items) {
        if (items.isEmpty) {
          return const EmptyState(text: 'No hay mantenimientos pendientes.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemBuilder: (context, index) {
            final item = items[index];
            return InfoCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.verdeClaroChip,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: AppColors.primario,
                  ),
                ),
                title: Text(
                  item.machineCode.isEmpty
                      ? 'Mantenimiento programado'
                      : item.machineCode,
                ),
                subtitle: Text(
                  [
                    item.description,
                    if (item.nextDate.isNotEmpty) 'Proximo: ${item.nextDate}',
                    item.frequency,
                    item.tasks,
                  ].where((text) => text.trim().isNotEmpty).join('\n'),
                ),
                isThreeLine: true,
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length,
        );
      },
    );
  }
}
