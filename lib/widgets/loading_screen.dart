import 'package:flutter/material.dart';

import '../theme.dart';

/// Pantalla/indicador de carga unico para toda la app, para que
/// cualquier lugar que este cargando datos (login, dashboard,
/// maquinas, mantenimiento, manuales, etc.) se vea igual.
///
/// Uso tipico:
///   if (cargando) return const LoadingScreen(mensaje: 'Cargando...');
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    this.mensaje = 'Cargando...',
    this.fondoTransparente = false,
    super.key,
  });

  /// Texto que se muestra debajo del indicador.
  final String mensaje;

  /// Si es true, no pinta un Scaffold completo (util cuando ya estas
  /// dentro de otro Scaffold/body y solo quieres el indicador centrado).
  final bool fondoTransparente;

  @override
  Widget build(BuildContext context) {
    final contenido = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.verdeClaroChip,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: AppColors.primario,
                strokeWidth: 3.2,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            mensaje,
            style: const TextStyle(
              color: AppColors.textoLabel,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );

    if (fondoTransparente) {
      return contenido;
    }

    return Scaffold(
      backgroundColor: AppColors.fondoFormulario,
      body: contenido,
    );
  }
}
