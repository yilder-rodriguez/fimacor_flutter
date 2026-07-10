import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';
import '../services/api_client.dart';
import '../widgets/future_panel.dart';
import '../widgets/hero_panel.dart';
import '../widgets/info_card.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.api,
    required this.onOpenMachines,
    super.key,
  });

  final ApiClient api;
  final VoidCallback onOpenMachines;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.dashboardSummary();
  }

  @override
  Widget build(BuildContext context) {
    return FuturePanel<DashboardSummary>(
      future: _future,
      onRefresh: () => setState(() => _future = widget.api.dashboardSummary()),
      builder: (context, summary) {
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            HeroPanel(
              title: 'Hola, cuentadante',
              subtitle: 'Resumen de tus maquinas asignadas',
              action: FilledButton.icon(
                onPressed: widget.onOpenMachines,
                icon: const Icon(Icons.precision_manufacturing_rounded),
                label: const Text('Ver maquinas'),
              ),
            ),
            const SizedBox(height: 14),
            MetricCard(
              icon: Icons.precision_manufacturing_rounded,
              label: 'Maquinas asignadas',
              value: '${summary.assignedMachines}',
              color: const Color(0xFF2666A3),
            ),
            const SizedBox(height: 12),
            MetricCard(
              icon: Icons.build_rounded,
              label: 'Mantenimientos pendientes',
              value: '${summary.pendingMaintenance}',
              color: const Color(0xFF10875F),
            ),
            const SizedBox(height: 12),
            MetricCard(
              icon: Icons.report_problem_rounded,
              label: 'Novedades abiertas',
              value: '${summary.openReports}',
              color: const Color(0xFF8A5A00),
            ),
            const SizedBox(height: 14),
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documentacion disponible',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text('${summary.manuals} manuales registrados para consulta.'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
