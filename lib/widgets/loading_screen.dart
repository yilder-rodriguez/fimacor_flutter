import 'package:flutter/material.dart';

import '../theme.dart';

/// Pantalla/indicador de carga unico para toda la app.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    this.mensaje = 'Cargando...',
    this.fondoTransparente = false,
    super.key,
  });

  final String mensaje;
  final bool fondoTransparente;

  @override
  Widget build(BuildContext context) {
    final contenido = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.verdeClaroChip, Color(0xFFDCF0E5)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
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

    if (fondoTransparente) return contenido;

    return Scaffold(
      backgroundColor: AppColors.fondoApp,
      body: contenido,
    );
  }
}
