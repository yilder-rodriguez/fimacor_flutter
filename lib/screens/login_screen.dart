import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/fimacor_theme.dart';
import '../widgets/fimacor_widgets.dart';
import '../data/fake_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  String _mensaje = '';
  bool _mensajeError = true;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _mensaje = '';
    });

    await Future.delayed(const Duration(seconds: 1));

    final usuario = FakeData.usuarios.where(
      (u) =>
          u['correo'] == _correoCtrl.text.trim() &&
          u['password'] == _passCtrl.text.trim(),
    );

    setState(() {
      _loading = false;
    });

    if (!mounted) return;

    if (usuario.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/menu');
    } else {
      setState(() {
        _mensaje = 'Correo o contraseña incorrectos';
        _mensajeError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;

    final esEscritorio = ancho >= 900;

    return Scaffold(
      appBar: const FimacorNavBar(showLinks: true),
      backgroundColor: FimacorColors.fondoOscuro,
      body: esEscritorio
          ? _layoutEscritorio()
          : SingleChildScrollView(
              child: _panelDerecho(),
            ),
    );
  }

  Widget _layoutEscritorio() {
    return Row(
      children: [
        Expanded(
          child: FimacorLeftPanel(
            titulo: 'Sistema de Gestión de',
            tituloSpan: 'Maquinaria Textil',
            descripcion:
                'FIMACOR centraliza el control de mantenimiento preventivo, correctivo y predictivo de la maquinaria textil del Centro de Manufactura Textil y del Cuero del SENA.',
            items: const [
              'Registro de mantenimientos preventivo, correctivo y predictivo',
              'Gestión de fichas técnicas y manuales',
              'Alertas automáticas',
              'Control de acceso por roles',
            ],
            showTeam: true,
          ),
        ),
        SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: _panelDerecho(),
          ),
        ),
      ],
    );
  }

  Widget _panelDerecho() {
    return Container(
      color: FimacorColors.fondoFormulario,
      constraints: const BoxConstraints(minHeight: 650),
      padding: const EdgeInsets.symmetric(
        horizontal: 36,
        vertical: 40,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
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
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bienvenido a FIMACOR',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: FimacorColors.textoOscuro,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ingresa tus credenciales para continuar',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: FimacorColors.textoMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const SenaBadge(),

            const SizedBox(height: 20),

            FimacorMensaje(
              texto: _mensaje,
              esError: _mensajeError,
            ),

            FimacorTextField(
              label: 'Correo Electrónico',
              hint: 'ejemplo@correo.com',
              controller: _correoCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu correo';
                }

                if (!value.contains('@')) {
                  return 'Correo inválido';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            FimacorPasswordField(
              label: 'Contraseña',
              hint: 'Ingresa tu contraseña',
              controller: _passCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: FimacorColors.primario,
                    ),
                  )
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text(
                      'Iniciar Sesión',
                    ),
                  ),

            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: FimacorColors.textoMuted,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/registro',
                          );
                        },
                        child: Text(
                          'Regístrate aquí',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: FimacorColors.primario,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/recuperar',
                      );
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: FimacorColors.primario,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Text(
                    'Usuarios de prueba',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('admin@fimacor.com / 123456'),
                  Text('tecnico@fimacor.com / 123456'),
                  Text('aprendiz@fimacor.com / 123456'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const FimacorFooter(),
          ],
        ),
      ),
    );
  }
}