import 'package:flutter/material.dart';

import '../theme.dart';

/// Lista de tips. Se muestra uno distinto segun el dia del anio,
/// igual que el "Tip del dia" del Menu.jsp en la version web
/// (ahi el tip lo calcula el backend; aqui, mientras no venga por
/// API, rotamos localmente para tener siempre un tip util visible).
const List<String> _tips = [
  'Registra las fallas apenas se detecten para evitar danios mayores.',
  'Revisa el estado de tus maquinas asignadas antes de iniciar la jornada.',
  'Mantener el area de trabajo limpia prolonga la vida util de la maquina.',
  'Reporta cualquier ruido extranio: puede ser el inicio de una falla mayor.',
  'Consulta el manual antes de operar una maquina que no conoces bien.',
  'Un mantenimiento preventivo a tiempo evita paradas de produccion.',
  'Verifica que la maquina este correctamente ubicada tras un traslado.',
];

String _tipDelDia() {
  final diaDelAnio = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;
  return _tips[diaDelAnio % _tips.length];
}

/// Tarjeta con un "bot" simple (icono dentro de un circulo) dando el
/// tip del dia dentro de una burbuja de chat, en el estilo Material
/// del resto de la app.
class TipBotCard extends StatelessWidget {
  const TipBotCard({this.tip, super.key});

  /// Si no se pasa un tip especifico, se usa el tip del dia calculado
  /// localmente (rotacion simple por dia del anio).
  final String? tip;

  @override
  Widget build(BuildContext context) {
    final mensaje = tip ?? _tipDelDia();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar del bot.
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.primario,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: AppColors.textoClaro,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        // Burbuja de texto con el tip.
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.verdeClaroChip,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppColors.acento.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      size: 16,
                      color: AppColors.primarioOscuro,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tip del dia',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primarioOscuro,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mensaje,
                  style: const TextStyle(
                    color: AppColors.textoOscuro,
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
