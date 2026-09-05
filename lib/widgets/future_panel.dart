import 'package:flutter/material.dart';

import '../theme.dart';
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
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9E0),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 34,
                      color: Color(0xFFC65A2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textoLabel),
                  ),
                  const SizedBox(height: 16),
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
