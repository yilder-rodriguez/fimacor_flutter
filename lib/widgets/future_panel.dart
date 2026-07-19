import 'package:flutter/material.dart';

import 'loading_screen.dart';

class FuturePanel<T> extends StatelessWidget {
  const FuturePanel({
    required this.future,
    required this.builder,
    required this.onRefresh,
    this.mensajeCarga = 'Cargando...',
    super.key,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRefresh;

  /// Texto mostrado en la pantalla de carga mientras se resuelve el
  /// future (para que cada pantalla pueda personalizarlo, ej.
  /// "Cargando maquinas...", "Cargando mantenimientos...").
  final String mensajeCarga;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen(
            mensaje: mensajeCarga,
            fondoTransparente: true,
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48),
                  const SizedBox(height: 12),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: builder(context, snapshot.data as T),
        );
      },
    );
  }
}
