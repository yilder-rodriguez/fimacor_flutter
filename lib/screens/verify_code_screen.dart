import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/app_snack.dart';
import '../widgets/brand_header.dart';
import 'login_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({required this.api, required this.correo, super.key});

  final ApiClient api;
  final String correo;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codigoController = TextEditingController();
  var _verificando = false;
  var _reenviando = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _verificar() async {
    final codigo = _codigoController.text.trim();
    if (codigo.length != 6) {
      showAppSnack(context, 'El codigo tiene 6 digitos.');
      return;
    }
    setState(() => _verificando = true);
    try {
      final resultado = await widget.api.verifyRegisterCode(codigo);
      if (!mounted) return;
      if (resultado.ok) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        showAppSnack(context, resultado.message ?? 'Cuenta creada. Ya puedes iniciar sesion.');
      } else {
        showAppSnack(context, resultado.message ?? 'Codigo incorrecto.');
      }
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  Future<void> _reenviar() async {
    setState(() => _reenviando = true);
    try {
      final resultado = await widget.api.resendRegisterCode();
      if (!mounted) return;
      showAppSnack(context, resultado.message ?? (resultado.ok ? 'Codigo reenviado.' : 'No se pudo reenviar.'));
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _reenviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BrandHeader(),
                    const SizedBox(height: 24),
                    Text(
                      'Verifica tu correo',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF16352D),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enviamos un codigo de 6 digitos a ${widget.correo}. Tienes 15 minutos para ingresarlo.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF60746E),
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _codigoController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, letterSpacing: 8),
                      decoration: const InputDecoration(
                        labelText: 'Codigo',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _verificando ? null : _verificar,
                      icon: _verificando
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(_verificando ? 'Verificando...' : 'Verificar y crear cuenta'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _reenviando ? null : _reenviar,
                      child: Text(_reenviando ? 'Reenviando...' : 'Reenviar codigo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
