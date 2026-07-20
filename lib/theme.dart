import 'package:flutter/material.dart';

/// Paleta de colores tomada directamente de Estyle.css/Style.css
/// (el mismo CSS que usa la version web en NetBeans), para que la
/// app movil se vea consistente con el sistema FIMACOR.
class AppColors {
  AppColors._();

  static const primario = Color(0xFF2E7D32);
  static const primarioOscuro = Color(0xFF1B5E20);
  static const acento = Color(0xFF4CAF50);
  static const fondoOscuro = Color(0xFF0D1B2A);
  static const fondoOscuroVerdoso = Color(0xFF1A3A2A);
  static const fondoFormulario = Color(0xFFF8FAF8);
  static const textoClaro = Color(0xFFFFFFFF);
  static const textoOscuro = Color(0xFF333333);
  static const textoLabel = Color(0xFF666666);
  static const bordeInput = Color(0xFFE0E0E0);
  static const verdeClaroChip = Color(0xFFE8F5E9);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primario,
        primary: AppColors.primario,
        secondary: AppColors.acento,
      ),
      scaffoldBackgroundColor: AppColors.fondoFormulario,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fondoOscuro,
        foregroundColor: AppColors.textoClaro,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.textoClaro,
        indicatorColor: AppColors.verdeClaroChip,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primario : AppColors.textoLabel,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primario : AppColors.textoLabel,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primario,
          foregroundColor: AppColors.textoClaro,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.bordeInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.bordeInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primario, width: 1.6),
        ),
      ),
    );
  }
}
