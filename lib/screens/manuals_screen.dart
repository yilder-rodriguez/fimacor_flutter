import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/manual_item.dart';
import '../services/api_client.dart';
import '../widgets/app_snack.dart';
import '../widgets/empty_state.dart';
import '../widgets/future_panel.dart';
import '../widgets/info_card.dart';

class ManualsScreen extends StatefulWidget {
  const ManualsScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<ManualsScreen> createState() => _ManualsScreenState();
}

class _ManualsScreenState extends State<ManualsScreen> {
  late Future<List<ManualItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.manuals();
  }

  Future<void> _openUrl(String url, String fallbackMessage) async {
    if (url.trim().isEmpty) {
      showAppSnack(context, fallbackMessage);
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      showAppSnack(context, 'El enlace del manual no es valido.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      showAppSnack(context, 'No se pudo abrir el manual.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FuturePanel<List<ManualItem>>(
      future: _future,
      onRefresh: () => setState(() => _future = widget.api.manuals()),
      builder: (context, manuals) {
        if (manuals.isEmpty) {
          return const EmptyState(text: 'No hay manuales disponibles.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemBuilder: (context, index) {
            final manual = manuals[index];
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.menu_book_rounded),
                        title: Text(manual.title),
                        subtitle: Text(
                          [
                            manual.type,
                            if (manual.machineCode.isNotEmpty)
                              'Maquina: ${manual.machineCode}',
                          ].where((text) => text.trim().isNotEmpty).join('\n'),
                        ),
                        isThreeLine: manual.machineCode.isNotEmpty,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () => _openUrl(
                              manual.openUrl,
                              'Este manual no tiene archivo para abrir.',
                            ),
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Abrir'),
                          ),
                          FilledButton.icon(
                            onPressed: () => _openUrl(
                              manual.downloadUrl,
                              'Este manual no tiene archivo para descargar.',
                            ),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Descargar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: manuals.length,
        );
      },
    );
  }
}
