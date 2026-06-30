import 'package:flutter/material.dart';
import '../widgets/fimacor_widgets.dart';
import '../theme/fimacor_theme.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FimacorNavBar(showLinks: true),
      backgroundColor: FimacorColors.fondoFormulario,
      body: Center(
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SenaBadge(),
                  const SizedBox(height: 25),

                  FimacorTextField(
                    label: 'Nombre Completo',
                    hint: 'Juan Pérez',
                    controller: nombreCtrl,
                  ),

                  const SizedBox(height: 15),

                  FimacorTextField(
                    label: 'Correo',
                    hint: 'correo@sena.edu.co',
                    controller: correoCtrl,
                  ),

                  const SizedBox(height: 15),

                  FimacorPasswordField(
                    label: 'Contraseña',
                    hint: '********',
                    controller: passCtrl,
                  ),

                  const SizedBox(height: 15),

                  FimacorPasswordField(
                    label: 'Confirmar Contraseña',
                    hint: '********',
                    controller: pass2Ctrl,
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Usuario registrado correctamente',
                          ),
                        ),
                      );

                      Navigator.pushReplacementNamed(
                        context,
                        '/',
                      );
                    },
                    child: const Text(
                      'Crear Cuenta',
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