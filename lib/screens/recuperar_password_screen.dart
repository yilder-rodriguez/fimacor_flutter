import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class RecuperarPasswordScreen extends StatelessWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recuperar Contraseña',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const CustomTextField(
              label: 'Correo Electrónico',
            ),

            CustomButton(
              texto: 'Enviar enlace',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}