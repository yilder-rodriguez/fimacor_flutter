import 'package:flutter/material.dart';
import '../widgets/sena_logo.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'registro_screen.dart';
import 'recuperar_password_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 40),

            const SenaLogo(),

            const SizedBox(height: 30),

            const CustomTextField(
              label: 'Correo Electrónico',
            ),

            const CustomTextField(
              label: 'Contraseña',
              obscureText: true,
            ),

            CustomButton(
              texto: 'Iniciar Sesión',
              onPressed: () {},
            ),

            TextButton(
              child: const Text('Regístrate aquí'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegistroScreen(),
                  ),
                );
              },
            ),

            TextButton(
              child: const Text('¿Olvidaste tu contraseña?'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const RecuperarPasswordScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}