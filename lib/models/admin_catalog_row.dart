import 'json_helpers.dart';

/// Fila generica de una tabla de catalogo. El backend expone todas las
/// tablas de catalogo con la misma forma ({id, campos}) para poder
/// reutilizar una unica pantalla de administracion en el cliente.
class AdminCatalogRow {
  const AdminCatalogRow({required this.id, required this.campos});

  final int id;
  final Map<String, String> campos;

  factory AdminCatalogRow.fromJson(Map<String, dynamic> json) {
    final campos = <String, String>{};
    final mapaCampos = json['campos'];
    if (mapaCampos is Map) {
      mapaCampos.forEach((key, value) {
        campos[key.toString()] = (value ?? '').toString();
      });
    }
    return AdminCatalogRow(id: asInt(json['id']), campos: campos);
  }
}
