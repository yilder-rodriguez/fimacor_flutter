import 'package:flutter/material.dart';
import 'package:fimacor_flutter/widgets/custom_textfield.dart';
import 'package:fimacor_flutter/widgets/custom_button.dart';
import 'package:fimacor_flutter/screens/registro_screen.dart';
import 'package:fimacor_flutter/screens/recuperar_password_screen.dart';
import 'package:fimacor_flutter/widgets/sena_logo.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static const _verde = Color(0xFF2E7D32);
  static const _verdeOsc = Color(0xFF1B5E20);
  static const _fondoOscuro = Color(0xFF0D1B2A);
  static const _fondoFormulario = Color(0xFFF8FAF8);
  static const _acento = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoOscuro,
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_fondoOscuro, Color(0xFF1A3A2A)],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x262E7D32),
                      border: Border.all(color: const Color(0x4D4CAF50)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SISTEMA DE GESTIÓN',
                      style: TextStyle(
                        color: _acento,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'Gestión de\nMaquinaria '),
                        TextSpan(
                          text: 'Textil',
                          style: TextStyle(color: _acento),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Plataforma integral para el control y mantenimiento\nde maquinaria en el sector textil y del cuero.',
                    style: TextStyle(
                      color: Color(0x99FFFFFF),
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: Color(0x1AFFFFFF)),
                  const SizedBox(height: 20),
                  const Text(
                    'EQUIPO CODEFUSION YD',
                    style: TextStyle(
                      color: Color(0x66FFFFFF),
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _TeamMember(iniciales: 'YR', nombre: 'Yilder', rol: 'Desarrollador'),
                      const SizedBox(width: 20),
                      _TeamMember(iniciales: 'DO', nombre: 'Daniel', rol: 'Desarrollador'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 460,
            color: _fondoFormulario,
            padding: const EdgeInsets.all(50),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SenaLogo(),
                    const SizedBox(height: 30),
                    const CustomTextField(label: 'Correo Electrónico'),
                    const CustomTextField(label: 'Contraseña', obscureText: true),
                    const SizedBox(height: 5),
                    CustomButton(texto: 'Iniciar Sesión', onPressed: () {}),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegistroScreen()),
                      ),
                      child: const Text(
                        'Regístrate aquí',
                        style: TextStyle(color: _verde, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RecuperarPasswordScreen()),
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: _verde, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String iniciales;
  final String nombre;
  final String rol;

  const _TeamMember({
    required this.iniciales,
    required this.nombre,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            iniciales,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(rol, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
          ],
        ),
      ],
    );
  }
}