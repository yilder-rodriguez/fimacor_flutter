import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de FIMACOR, tomada directamente del emblema real del proyecto
/// (el pictograma verde sobre fondo tinta), no de una paleta Material
/// generica. La idea de fondo: esto es una herramienta tecnica de
/// mantenimiento de maquinaria -una ficha de taller-, no una app de
/// consumo, asi que la superficie base es un "papel" calido de hoja de
/// ficha tecnica en vez del blanco/menta por defecto.
class AppColors {
  AppColors._();

  // Marca: verde tomado del degradado real del pictograma FIMACOR.
  static const primario = Color(0xFF2F9C63);
  static const primarioOscuro = Color(0xFF1B6B45);
  static const primarioClaro = Color(0xFF8AD98A);
  static const acento = Color(0xFF2F9C63);

  // Tinta: el mismo tono casi-negro del fondo del emblema.
  static const tinta = Color(0xFF0A0F1C);
  static const tintaAlterna = Color(0xFF121A2B);
  // Alias retrocompatibles con pantallas ya escritas.
  static const fondoOscuro = tinta;
  static const fondoOscuroVerdoso = tintaAlterna;

  // Superficies: papel calido de ficha tecnica, no blanco/menta generico.
  static const fondoApp = Color(0xFFF1EEE7);
  static const superficie = Color(0xFFFFFDF9);
  static const superficieAlterna = Color(0xFFE9E4D8);

  // Texto
  static const textoClaro = Color(0xFFFFFDF9);
  static const textoOscuro = Color(0xFF1B2027);
  static const textoLabel = Color(0xFF5B6772);
  static const textoTenue = Color(0xFF8A93A0);

  // Estructura: acero, para bordes y divisores en vez de sombras suaves.
  static const acero = Color(0xFF45525E);
  static const bordeInput = Color(0xFFD8D2C4);
  static const bordePlaca = Color(0xFFDAD4C6);
  static const verdeClaroChip = Color(0xFFDCEEE0);

  // Ambar de aviso: mantenimiento pendiente / estados de atencion,
  // como una etiqueta de advertencia industrial.
  static const ambar = Color(0xFFE2A33D);
  static const ambarClaro = Color(0xFFF7E6C4);
  static const peligro = Color(0xFFC0392B);
  static const peligroClaro = Color(0xFFF6DAD5);

  // Acento por rol/seccion: version acotada a la nueva paleta (menos
  // saturada, mas "senalizacion tecnica" que arcoiris de Material).
  static const rolCuentadante = Color(0xFF2B6C8F);
  static const rolTecnico = Color(0xFFB1592B);
  static const rolAdministrador = Color(0xFF5C4A94);
  static const rolLogistica = Color(0xFF0F7C7C);
  static const rolInstructor = Color(0xFF8A6A22);
  static const rolAprendiz = Color(0xFF2E7D4F);
  static const rolSubdireccion = Color(0xFF8C3A5C);

  static const gradienteOscuro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tinta, tintaAlterna],
  );

  static const gradientePrimario = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarioOscuro, primario],
  );

  /// El mismo degradado verde del pictograma real (claro arriba,
  /// profundo abajo), para usarlo en el hero del login.
  static const gradienteEmblema = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primarioClaro, primario, primarioOscuro],
  );

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

/// Radios pequenos y casi rectos (ficha tecnica, no burbuja de app de
/// consumo). Se dejan los mismos nombres para no romper pantallas ya
/// escritas, pero con valores mucho mas chicos.
class AppRadius {
  AppRadius._();
  static const sm = 4.0;
  static const md = 6.0;
  static const lg = 8.0;
  static const xl = 12.0;
}

/// Estilos de texto que no forman parte del TextTheme por defecto:
/// especificamente la fuente monoespaciada para codigos de maquina,
/// documentos, fechas e IDs -igual que una placa de serie- para que
/// esos datos se lean como datos tecnicos y no como prosa.
class AppText {
  AppText._();

  static TextStyle codigo({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textoOscuro,
    double? letterSpacing,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primario,
        brightness: Brightness.light,
        primary: AppColors.primario,
        secondary: AppColors.ambar,
        surface: AppColors.superficie,
      ),
      scaffoldBackgroundColor: AppColors.fondoApp,
      useMaterial3: true,
      splashFactory: InkRipple.splashFactory,
    );

    final textTheme = GoogleFonts.ibmPlexSansTextTheme(base.textTheme).copyWith(
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textoOscuro,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        color: AppColors.textoOscuro,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w600,
        color: AppColors.textoOscuro,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w600,
        color: AppColors.textoOscuro,
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        color: AppColors.textoOscuro,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.ibmPlexSans(color: AppColors.textoLabel, height: 1.4),
      labelLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.tinta,
        foregroundColor: AppColors.textoClaro,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
        toolbarHeight: 64,
        shape: const Border(
          bottom: BorderSide(color: AppColors.primarioClaro, width: 3),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.superficie,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.primario.withValues(alpha: 0.14),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.ibmPlexSans(
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
          side: const BorderSide(color: AppColors.bordePlaca),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.superficieAlterna,
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textoOscuro,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: const BorderSide(color: AppColors.bordePlaca),
        ),
        side: const BorderSide(color: AppColors.bordePlaca),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.superficie,
          selectedBackgroundColor: AppColors.primario,
          selectedForegroundColor: Colors.white,
          foregroundColor: AppColors.textoOscuro,
          side: const BorderSide(color: AppColors.bordeInput),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 13),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primario,
          foregroundColor: AppColors.textoClaro,
          textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 14.5),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primarioOscuro,
          side: const BorderSide(color: AppColors.acero, width: 1.3),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primarioOscuro,
          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.tinta,
        foregroundColor: Colors.white,
        extendedTextStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.tinta,
        contentTextStyle: GoogleFonts.ibmPlexSans(color: Colors.white, fontSize: 13.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        labelStyle: GoogleFonts.ibmPlexSans(color: AppColors.textoLabel, fontSize: 13.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.bordeInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.bordeInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primario, width: 1.8),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.bordePlaca, space: 32),
    );
  }
}
