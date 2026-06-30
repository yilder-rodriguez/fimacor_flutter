import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FimacorColors {
  // Colores principales
  static const Color primario = Color(0xFF2E7D32);
  static const Color primarioOscuro = Color(0xFF1B5E20);
  static const Color acento = Color(0xFF4CAF50);
  static const Color acentoClaro = Color(0xFFA5D6A7);

  // Fondos
  static const Color fondoOscuro = Color(0xFF0D1B2A);
  static const Color fondoOscuroMedio = Color(0xFF1A2F3F);
  static const Color fondoFormulario = Color(0xFFF8FAF8);
  static const Color fondoCard = Color(0xFFFFFFFF);

  // Textos
  static const Color textoClaro = Color(0xFFFFFFFF);
  static const Color textoClaroSuave = Color(0x99FFFFFF);
  static const Color textoOscuro = Color(0xFF333333);
  static const Color textoLabel = Color(0xFF666666);
  static const Color textoMuted = Color(0xFF999999);

  // Bordes
  static const Color bordeInput = Color(0xFFE0E0E0);

  // Estados
  static const Color verde = Color(0xFF4CAF50);
  static const Color amarillo = Color(0xFFFFC107);
  static const Color rojo = Color(0xFFF44336);
}

class FimacorTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: FimacorColors.primario,
          primary: FimacorColors.primario,
          secondary: FimacorColors.acento,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
        scaffoldBackgroundColor: FimacorColors.fondoFormulario,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: FimacorColors.primario,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: FimacorColors.bordeInput),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: FimacorColors.primario,
              width: 2,
            ),
          ),
        ),
      );
}