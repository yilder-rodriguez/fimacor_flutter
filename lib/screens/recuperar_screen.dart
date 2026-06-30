import 'package:flutter/material.dart';
import '../widgets/fimacor_widgets.dart';

class RecuperarScreen extends StatefulWidget {
  const RecuperarScreen({super.key});

  @override
  State<RecuperarScreen> createState() => _RecuperarScreenState();
}

class _RecuperarScreenState extends State<RecuperarScreen> {
  final correoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FimacorNavBar(),
      body: Center(
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SenaBadge(),
                const SizedBox(height: 20),
                FimacorTextField(
                  label: 'Correo',
                  hint: 'correo@sena.edu.co',
                  controller: correoCtrl,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Correo enviado correctamente',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Enviar enlace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}