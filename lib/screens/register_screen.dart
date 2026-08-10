import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/register_role.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/app_snack.dart';
import '../widgets/brand_header.dart';
import 'verify_code_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  static const _tiposDocumento = [
    ('CC', 'Cedula de Ciudadania'),
    ('TI', 'Tarjeta de Identidad'),
    ('CE', 'Cedula de Extranjeria'),
  ];

  String? _tipoDoc;
  RegisterRole? _rolSeleccionado;
  List<RegisterRole> _roles = [];
  var _cargandoRoles = true;
  var _obscure = true;
  var _enviando = false;

  File? _fotoCarnet;
  var _analizandoCarnet = false;
  String? _carnetDocumentoDetectado;
  String? _carnetRolDetectado;

  @override
  void initState() {
    super.initState();
    _cargarRoles();
  }

  Future<void> _cargarRoles() async {
    try {
      final roles = await widget.api.fetchRegisterRoles();
      if (!mounted) return;
      setState(() {
        _roles = roles;
        _cargandoRoles = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _cargandoRoles = false);
      showAppSnack(context, 'No se pudieron cargar los roles disponibles.');
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _elegirFotoCarnet(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() {
      _fotoCarnet = file;
      _carnetDocumentoDetectado = null;
      _carnetRolDetectado = null;
      _analizandoCarnet = true;
    });
    try {
      final resultado = await widget.api.analyzeCarnet(file);
      if (!mounted) return;
      setState(() {
        _analizandoCarnet = false;
        _carnetDocumentoDetectado = resultado.documento;
        _carnetRolDetectado = resultado.rol;
      });
      if (!resultado.ok) {
        showAppSnack(
          context,
          resultado.message ?? 'No se pudo leer el carnet, intenta con otra foto.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _analizandoCarnet = false);
      showAppSnack(context, 'No se pudo analizar el carnet: $error');
    }
  }

  bool get _carnetListo =>
      _carnetDocumentoDetectado != null &&
      _carnetDocumentoDetectado!.isNotEmpty &&
      _carnetRolDetectado != null &&
      _carnetRolDetectado!.isNotEmpty;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rolSeleccionado == null) {
      showAppSnack(context, 'Selecciona un rol.');
      return;
    }
    if (_tipoDoc == null) {
      showAppSnack(context, 'Selecciona el tipo de documento.');
      return;
    }
    if (!_carnetListo) {
      showAppSnack(context, 'Valida tu carnet SENA (foto) antes de continuar.');
      return;
    }

    setState(() => _enviando = true);
    try {
      final resultado = await widget.api.registerUser(
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        documento: _documentoController.text,
        telefono: _telefonoController.text,
        correo: _correoController.text,
        contrasena: _contrasenaController.text,
        tipoDoc: _tipoDoc!,
        idRol: _rolSeleccionado!.idRol,
        carnetDocumento: _carnetDocumentoDetectado!,
        carnetRol: _carnetRolDetectado!,
      );
      if (!mounted) return;
      if (resultado.ok) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VerifyCodeScreen(
              api: widget.api,
              correo: _correoController.text.trim(),
            ),
          ),
        );
      } else {
        showAppSnack(context, resultado.message ?? 'No se pudo registrar.');
      }
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoOscuro,
        foregroundColor: AppColors.textoClaro,
        elevation: 0,
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BrandHeader(),
                      const SizedBox(height: 24),
                      Text(
                        'Registro (Aprendiz, Instructor, Tecnico o Logistica)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF16352D),
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cuentadante, Administrador y Subdireccion los crea un administrador desde el sistema.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textoLabel,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(labelText: 'Nombre'),
                              validator: _requerido,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _apellidoController,
                              decoration: const InputDecoration(labelText: 'Apellido'),
                              validator: _requerido,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _tipoDoc,
                        decoration: const InputDecoration(labelText: 'Tipo de documento'),
                        items: _tiposDocumento
                            .map((tipo) => DropdownMenuItem(
                                  value: tipo.$1,
                                  child: Text(tipo.$2),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _tipoDoc = value),
                        validator: (value) => value == null ? 'Selecciona el tipo de documento.' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _documentoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Numero de documento'),
                        validator: _requerido,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Telefono'),
                        validator: _requerido,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Correo'),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Ingresa el correo.';
                          if (!text.contains('@')) return 'Correo no valido.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _contrasenaController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Contrasena',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().length < 6) {
                            return 'Minimo 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _cargandoRoles
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: LinearProgressIndicator(),
                            )
                          : DropdownButtonFormField<RegisterRole>(
                              initialValue: _rolSeleccionado,
                              decoration: const InputDecoration(labelText: 'Rol'),
                              items: _roles
                                  .map((rol) => DropdownMenuItem(
                                        value: rol,
                                        child: Text(rol.nombre),
                                      ))
                                  .toList(),
                              onChanged: (value) => setState(() => _rolSeleccionado = value),
                              validator: (value) => value == null ? 'Selecciona un rol.' : null,
                            ),
                      const SizedBox(height: 20),
                      _buildCarnetSection(context),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _enviando ? null : _submit,
                        icon: _enviando
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.how_to_reg_rounded),
                        label: Text(_enviando ? 'Enviando...' : 'Crear cuenta'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Ya tengo cuenta, ingresar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarnetSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.verdeClaroChip,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primario.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: AppColors.primarioOscuro),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Validacion obligatoria: foto del carnet SENA',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF16352D),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _analizandoCarnet
                      ? null
                      : () => _elegirFotoCarnet(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camara'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _analizandoCarnet
                      ? null
                      : () => _elegirFotoCarnet(ImageSource.gallery),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Galeria'),
                ),
              ),
            ],
          ),
          if (_analizandoCarnet) ...[
            const SizedBox(height: 10),
            const Row(
              children: [
                SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Analizando carnet...'),
              ],
            ),
          ] else if (_fotoCarnet != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  _carnetListo ? Icons.check_circle : Icons.error_outline,
                  color: _carnetListo ? AppColors.primario : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _carnetListo
                        ? 'Detectado: doc. $_carnetDocumentoDetectado - rol $_carnetRolDetectado'
                        : 'No se pudo confirmar el documento o el rol en la foto.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String? _requerido(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Este campo es obligatorio.';
    return null;
  }
}
