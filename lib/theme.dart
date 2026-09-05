import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de colores de FIMACOR. Mantiene el verde institucional del
/// SENA como color de marca, pero con un set mas rico (superficies,
/// degradados, colores de acento por rol) para lograr una interfaz
/// mas moderna y con mas jerarquia visual que la version anterior.
class AppColors {
  AppColors._();

  // Marca / verde SENA
  static const primario = Color(0xFF1E8E4E);
  static const primarioOscuro = Color(0xFF0F5C33);
  static const primarioClaro = Color(0xFF57C285);
  static const acento = Color(0xFF34D399);

  // Fondos oscuros (login, encabezados hero)
  static const fondoOscuro = Color(0xFF0B1C22);
  static const fondoOscuroVerdoso = Color(0xFF0E3B2E);

  // Superficies claras
  static const fondoApp = Color(0xFFF3F7F5);
  static const superficie = Color(0xFFFFFFFF);
  static const superficieAlterna = Color(0xFFEFF7F2);

  // Texto
  static const textoClaro = Color(0xFFFFFFFF);
  static const textoOscuro = Color(0xFF17241F);
  static const textoLabel = Color(0xFF667069);
  static const textoTenue = Color(0xFF8C9992);

  static const bordeInput = Color(0xFFE1E9E4);
  static const verdeClaroChip = Color(0xFFE3F6EC);

  // Colores de acento por rol/seccion, para reforzar visualmente
  // que cada vista pertenece a un rol distinto.
  static const rolCuentadante = Color(0xFF2666A3);
  static const rolTecnico = Color(0xFFC65A2E);
  static const rolAdministrador = Color(0xFF6B4FBB);
  static const rolLogistica = Color(0xFF0F7C8C);
  static const rolInstructor = Color(0xFF8A5A00);
  static const rolAprendiz = Color(0xFF2E7D32);
  static const rolSubdireccion = Color(0xFF9C2B5B);

  static const gradienteOscuro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [fondoOscuro, fondoOscuroVerdoso],
  );

  static const gradientePrimario = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarioOscuro, primario],
  );

  /// Color de acento asociado a un rol (para chips, iconos, avatares).
  static Color paraRol(String? rol) {
    final r = (rol ?? '').toLowerCase();
    if (r.contains('cuentadante')) return rolCuentadante;
    if (r.contains('tecnico')) return rolTecnico;
    if (r.contains('administrador')) return rolAdministrador;
    if (r.contains('logistica')) return rolLogistica;
    if (r.contains('instructor')) return rolInstructor;
    if (r.contains('aprendiz')) return rolAprendiz;
    if (r.contains('subdireccion')) return rolSubdireccion;
    return primario;
  }

  static IconData iconoParaRol(String? rol) {
    final r = (rol ?? '').toLowerCase();
    if (r.contains('cuentadante')) return Icons.inventory_2_rounded;
    if (r.contains('tecnico')) return Icons.handyman_rounded;
    if (r.contains('administrador')) return Icons.admin_panel_settings_rounded;
    if (r.contains('logistica')) return Icons.local_shipping_rounded;
    if (r.contains('instructor')) return Icons.school_rounded;
    if (r.contains('aprendiz')) return Icons.menu_book_rounded;
    if (r.contains('subdireccion')) return Icons.verified_rounded;
    return Icons.verified_user_rounded;
  }
}

class AppRadius {
  AppRadius._();
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 26.0;
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primario,
        primary: AppColors.primario,
        secondary: AppColors.acento,
        surface: AppColors.superficie,
      ),
      scaffoldBackgroundColor: AppColors.fondoApp,
      useMaterial3: true,
      splashFactory: InkSparkle.splashFactory,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textoOscuro,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w800,
        color: AppColors.textoOscuro,
      ),
      titleMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppColors.textoOscuro,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: AppColors.textoOscuro,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.poppins(color: AppColors.textoLabel),
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.fondoOscuro,
        foregroundColor: AppColors.textoClaro,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        toolbarHeight: 64,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.superficie,
        elevation: 3,
        height: 68,
        indicatorColor: AppColors.verdeClaroChip,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primarioOscuro : AppColors.textoLabel,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primarioOscuro : AppColors.textoTenue,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.superficieAlterna,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textoOscuro,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.superficie,
          selectedBackgroundColor: AppColors.primario,
          selectedForegroundColor: Colors.white,
          foregroundColor: AppColors.textoOscuro,
          side: const BorderSide(color: AppColors.bordeInput),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primario,
          foregroundColor: AppColors.textoClaro,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14.5),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primarioOscuro,
          side: const BorderSide(color: AppColors.bordeInput, width: 1.3),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primarioOscuro,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF14231D),
        contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficieAlterna,
        labelStyle: GoogleFonts.poppins(color: AppColors.textoLabel, fontSize: 13.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primario, width: 1.8),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.bordeInput, space: 32),
    );
  }
}
