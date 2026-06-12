import 'package:flutter/material.dart';
import 'package:fimacor_flutter/widgets/custom_button.dart';
import 'package:fimacor_flutter/widgets/custom_textfield.dart';

class RecuperarPasswordScreen extends StatelessWidget {
  const RecuperarPasswordScreen({super.key});

  static const _verde = Color(0xFF2E7D32);
  static const _verdeOsc = Color(0xFF1B5E20);
  static const _fondoOscuro = Color(0xFF0D1B2A);
  static const _fondoCard = Color(0xFFFFFFFF);
  static const _acento = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_fondoOscuro, Color(0xFF1B4332)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 430,
              padding: const EdgeInsets.fromLTRB(35, 40, 35, 40),
              decoration: BoxDecoration(
                color: _fondoCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 40,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_verde, _acento],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: _verde,
                      size: 46,
                    ),
                  ),
                  const Text(
                    'Recuperar Contraseña',
                    style: TextStyle(
                      color: Color(0xFF1B4332),
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ingresa tu correo electrónico y te enviaremos\nun enlace para restablecer tu contraseña.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const CustomTextField(label: 'Correo Electrónico'),
                  const SizedBox(height: 5),
                  CustomButton(texto: 'Enviar enlace', onPressed: () {}),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '← Volver al inicio de sesión',
                      style: TextStyle(
                        color: _verde,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'SENA · Centro de Manufactura Textil y del Cuero\nFIMAR · CodeFusion YD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}