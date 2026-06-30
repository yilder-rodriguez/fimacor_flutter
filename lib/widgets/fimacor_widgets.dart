import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/fimacor_theme.dart';

class FimacorNavBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showLinks;
  final String? userInitials;
  final VoidCallback? onLogout;

  const FimacorNavBar({
    super.key,
    this.showLinks = false,
    this.userInitials,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: FimacorColors.fondoOscuro,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: FimacorColors.primario,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'FIMACOR',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        if (userInitials != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: FimacorColors.primario,
              child: Text(userInitials!),
            ),
          ),
      ],
    );
  }
}

class SenaBadge extends StatelessWidget {
  const SenaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: FimacorColors.primario.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Centro de Manufactura Textil y del Cuero · SENA',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class FimacorTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const FimacorTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }
}

class FimacorPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const FimacorPasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
  });

  @override
  State<FimacorPasswordField> createState() =>
      _FimacorPasswordFieldState();
}

class _FimacorPasswordFieldState
    extends State<FimacorPasswordField> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: !visible,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: IconButton(
              icon: Icon(
                visible
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  visible = !visible;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FimacorMensaje extends StatelessWidget {
  final String texto;
  final bool esError;

  const FimacorMensaje({
    super.key,
    required this.texto,
    this.esError = true,
  });

  @override
  Widget build(BuildContext context) {
    if (texto.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esError
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: esError ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}

class FimacorFooter extends StatelessWidget {
  const FimacorFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '© 2026 FIMACOR - CodeFusion YD',
      textAlign: TextAlign.center,
    );
  }
}

class FimacorLeftPanel extends StatelessWidget {
  final String titulo;
  final String tituloSpan;
  final String descripcion;
  final List<String> items;
  final bool showTeam;

  const FimacorLeftPanel({
    super.key,
    required this.titulo,
    required this.tituloSpan,
    required this.descripcion,
    required this.items,
    this.showTeam = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FimacorColors.fondoOscuro,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo $tituloSpan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            descripcion,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}