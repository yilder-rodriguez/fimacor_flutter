import 'package:flutter/material.dart';
import 'package:fimacor_flutter/widgets/custom_button.dart';
import 'package:fimacor_flutter/widgets/custom_textfield.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x332E7D32),
                      border: Border.all(color: const Color(0x4D4CAF50)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'REGISTRO DE USUARIO',
                      style: TextStyle(
                        color: _acento,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'Crea tu\n'),
                        TextSpan(
                          text: 'cuenta',
                          style: TextStyle(color: _acento),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Completa el formulario para acceder\na la plataforma de gestión textil.',
                    style: TextStyle(
                      color: Color(0x8CFFFFFF),
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _StepItem(numero: '1', texto: 'Ingresa tus datos personales'),
                  const SizedBox(height: 14),
                  _StepItem(numero: '2', texto: 'Crea una contraseña segura'),
                  const SizedBox(height: 14),
                  _StepItem(numero: '3', texto: 'Accede al sistema FIMACOR'),
                ],
              ),
            ),
          ),
          Container(
            width: 480,
            color: _fondoFormulario,
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 30),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'FIMACOR',
                            style: TextStyle(
                              color: Color(0xFF1A3A2A),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Completa tu registro',
                            style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                          ),
                          SizedBox(height: 12),
                          _SenaBadge(),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Row(
                      children: const [
                        Expanded(child: CustomTextField(label: 'Nombre')),
                        SizedBox(width: 10),
                        Expanded(child: CustomTextField(label: 'Apellido')),
                      ],
                    ),
                    const CustomTextField(label: 'Correo'),
                    const CustomTextField(label: 'Teléfono'),
                    const CustomTextField(label: 'Documento'),
                    const CustomTextField(label: 'Contraseña', obscureText: true),
                    const CustomTextField(label: 'Confirmar Contraseña', obscureText: true),
                    const SizedBox(height: 4),
                    CustomButton(texto: 'Registrar Usuario', onPressed: () {}),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '¿Ya tienes cuenta? Inicia sesión',
                          style: TextStyle(
                            color: _verde,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'SENA · Centro de Manufactura Textil y del Cuero',
                        style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 10),
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

class _StepItem extends StatelessWidget {
  final String numero;
  final String texto;

  const _StepItem({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x264CAF50),
            border: Border.all(color: const Color(0x594CAF50)),
          ),
          alignment: Alignment.center,
          child: Text(
            numero,
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          texto,
          style: const TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _SenaBadge extends StatelessWidget {
  const _SenaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'SENA · Centro de Manufactura Textil y del Cuero',
        style: TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}