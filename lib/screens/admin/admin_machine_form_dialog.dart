import 'package:flutter/material.dart';

import '../../models/admin_machine.dart';
import '../../theme.dart';

/// Formulario de alta/edicion de maquina. El combo de modelo se filtra
/// segun la marca elegida, igual que valida el servidor.
class AdminMachineFormDialog extends StatefulWidget {
  const AdminMachineFormDialog({
    required this.catalogos,
    this.maquina,
    super.key,
  });

  final MachineCatalogs catalogos;
  final AdminMachine? maquina;

  @override
  State<AdminMachineFormDialog> createState() => _AdminMachineFormDialogState();
}

class _AdminMachineFormDialogState extends State<AdminMachineFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigoSena;
  late final TextEditingController _descripcion;
  late final TextEditingController _area;
  late final TextEditingController _fechaCompra;
  late final TextEditingController _valor;
  late final TextEditingController _fechaGarantia;

  int? _idMarca;
  int? _idModelo;
  int? _idTipo;
  int? _idAmbiente;
  int? _idSede;
  int? _idEstado;
  var _tieneGarantia = false;

  bool get _esNuevo => widget.maquina == null;

  @override
  void initState() {
    super.initState();
    final m = widget.maquina;
    _codigoSena = TextEditingController(text: m?.codigoSena ?? '');
    _descripcion = TextEditingController(text: m?.descripcion ?? '');
    _area = TextEditingController(text: m?.area ?? '');
    _fechaCompra = TextEditingController(text: m?.fechaCompra ?? '');
    _valor = TextEditingController(text: m?.valorMaquina ?? '');
    _fechaGarantia = TextEditingController(text: m?.fechaGarantia ?? '');
    _idMarca = m?.idMarca;
    _idModelo = m?.idModelo;
    _idTipo = m?.idTipo;
    _idAmbiente = m?.idAmbiente;
    _idSede = m?.idSede;
    _idEstado = m?.idEstado;
    _tieneGarantia = m?.tieneGarantia ?? false;
  }

  @override
  void dispose() {
    _codigoSena.dispose();
    _descripcion.dispose();
    _area.dispose();
    _fechaCompra.dispose();
    _valor.dispose();
    _fechaGarantia.dispose();
    super.dispose();
  }

  List<ModeloItem> get _modelosDeLaMarca =>
      widget.catalogos.modelos.where((m) => m.idMarca == _idMarca).toList();

  Future<void> _elegirFecha(TextEditingController controller) async {
    final ahora = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: ahora,
      firstDate: DateTime(2000),
      lastDate: DateTime(ahora.year + 15),
    );
    if (seleccionada != null) {
      controller.text =
          '${seleccionada.year.toString().padLeft(4, '0')}-${seleccionada.month.toString().padLeft(2, '0')}-${seleccionada.day.toString().padLeft(2, '0')}';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_idMarca == null || _idModelo == null || _idTipo == null ||
        _idAmbiente == null || _idSede == null || _idEstado == null) {
      return;
    }
    Navigator.of(context).pop({
      'codigoSena': _codigoSena.text.trim(),
      'descripcion': _descripcion.text.trim(),
      'idMarca': _idMarca,
      'idModelo': _idModelo,
      'idTipo': _idTipo,
      'idAmbiente': _idAmbiente,
      'idSede': _idSede,
      'idEstado': _idEstado,
      'area': _area.text.trim(),
      'fechaCompra': _fechaCompra.text.trim(),
      'valorMaquina': _valor.text.trim(),
      'tieneGarantia': _tieneGarantia,
      'fechaGarantia': _tieneGarantia ? _fechaGarantia.text.trim() : '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_esNuevo ? 'Nueva maquina' : 'Editar maquina'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codigoSena,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Codigo SENA'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcion,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _idMarca,
                        decoration: const InputDecoration(labelText: 'Marca'),
                        items: widget.catalogos.marcas
                            .map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _idMarca = v;
                          if (_modelosDeLaMarca.every((m) => m.id != _idModelo)) {
                            _idModelo = null;
                          }
                        }),
                        validator: (v) => v == null ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _idModelo,
                        decoration: const InputDecoration(labelText: 'Modelo'),
                        items: _modelosDeLaMarca
                            .map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)))
                            .toList(),
                        onChanged: (v) => setState(() => _idModelo = v),
                        validator: (v) => v == null ? 'Elige marca primero' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _idTipo,
                  decoration: const InputDecoration(labelText: 'Tipo de maquina'),
                  items: widget.catalogos.tipos
                      .map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _idTipo = v),
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _idSede,
                        decoration: const InputDecoration(labelText: 'Sede'),
                        items: widget.catalogos.sedes
                            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.nombre)))
                            .toList(),
                        onChanged: (v) => setState(() => _idSede = v),
                        validator: (v) => v == null ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _idAmbiente,
                        decoration: const InputDecoration(labelText: 'Ambiente'),
                        items: widget.catalogos.ambientes
                            .map((a) => DropdownMenuItem(value: a.id, child: Text(a.nombre)))
                            .toList(),
                        onChanged: (v) => setState(() => _idAmbiente = v),
                        validator: (v) => v == null ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _area,
                  decoration: const InputDecoration(labelText: 'Area / ubicacion especifica'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _idEstado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: widget.catalogos.estados
                      .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _idEstado = v),
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fechaCompra,
                        readOnly: true,
                        onTap: () => _elegirFecha(_fechaCompra),
                        decoration: const InputDecoration(
                          labelText: 'Fecha de compra',
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _valor,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Valor (COP)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primario,
                  title: const Text('Tiene garantia'),
                  value: _tieneGarantia,
                  onChanged: (v) => setState(() => _tieneGarantia = v),
                ),
                if (_tieneGarantia)
                  TextFormField(
                    controller: _fechaGarantia,
                    readOnly: true,
                    onTap: () => _elegirFecha(_fechaGarantia),
                    decoration: const InputDecoration(
                      labelText: 'Fecha de vencimiento de garantia',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                  ),
              ],
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
          child: Text(_esNuevo ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}
