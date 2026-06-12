import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Usuario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const CustomTextField(label: 'Nombre'),
            const CustomTextField(label: 'Apellido'),
            const CustomTextField(label: 'Correo'),
            const CustomTextField(label: 'Teléfono'),
            const CustomTextField(label: 'Documento'),

            const CustomTextField(
              label: 'Contraseña',
              obscureText: true,
            ),

            const CustomTextField(
              label: 'Confirmar Contraseña',
              obscureText: true,
            ),

            CustomButton(
              texto: 'Registrar Usuario',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}