import 'package:flutter/material.dart';

import '../../models/admin_catalog_row.dart';
import 'catalog_type_config.dart';

/// Formulario generico: arma un TextFormField o un Dropdown por cada
/// campo declarado en CatalogTypeConfig, sin importar cual catalogo sea.
class AdminCatalogFormDialog extends StatefulWidget {
  const AdminCatalogFormDialog({
    required this.config,
    required this.opcionesReferencia,
    this.fila,
    super.key,
  });

  final CatalogTypeConfig config;

  /// Para cada campo de tipo referencia (por su key), las filas
  /// disponibles del catalogo referenciado, ya cargadas.
  final Map<String, List<AdminCatalogRow>> opcionesReferencia;

  final AdminCatalogRow? fila;

  @override
  State<AdminCatalogFormDialog> createState() => _AdminCatalogFormDialogState();
}

class _AdminCatalogFormDialogState extends State<AdminCatalogFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controladores = {};
  final Map<String, int?> _seleccionReferencia = {};

  @override
  void initState() {
    super.initState();
    for (final campo in widget.config.campos) {
      final valorActual = widget.fila?.campos[campo.key] ?? '';
      if (campo.type == CatalogFieldType.referencia) {
        _seleccionReferencia[campo.key] = int.tryParse(valorActual);
      } else {
        _controladores[campo.key] = TextEditingController(text: valorActual);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controladores.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _nombreOpcion(CatalogTypeConfig referenciado, AdminCatalogRow fila) {
    final texto = fila.campos[referenciado.campoPrincipal.key] ?? '';
    return texto.isEmpty ? 'ID ${fila.id}' : texto;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    for (final campo in widget.config.campos) {
      if (campo.type == CatalogFieldType.referencia && _seleccionReferencia[campo.key] == null) {
        return;
      }
    }
    final valores = <String, String>{};
    for (final campo in widget.config.campos) {
      valores[campo.key] = campo.type == CatalogFieldType.referencia
          ? '${_seleccionReferencia[campo.key]}'
          : _controladores[campo.key]!.text.trim();
    }
    Navigator.of(context).pop(valores);
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.fila == null;
    return AlertDialog(
      title: Text(esNuevo ? 'Nuevo registro' : 'Editar registro'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.config.campos.map((campo) {
                final campoWidget = campo.type == CatalogFieldType.referencia
                    ? _buildReferencia(campo)
                    : TextFormField(
                        controller: _controladores[campo.key],
                        decoration: InputDecoration(labelText: campo.label),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: campoWidget,
                );
              }).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(esNuevo ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }

  Widget _buildReferencia(CatalogFieldConfig campo) {
    final referenciado =
        kCatalogTypes.firstWhere((c) => c.key == campo.referenciaCatalogo);
    final opciones = widget.opcionesReferencia[campo.key] ?? const <AdminCatalogRow>[];
    return DropdownButtonFormField<int>(
      initialValue: _seleccionReferencia[campo.key],
      decoration: InputDecoration(labelText: campo.label),
      items: opciones
          .map((o) => DropdownMenuItem(value: o.id, child: Text(_nombreOpcion(referenciado, o))))
          .toList(),
      onChanged: (v) => setState(() => _seleccionReferencia[campo.key] = v),
      validator: (v) => v == null ? 'Requerido' : null,
    );
  }
}
