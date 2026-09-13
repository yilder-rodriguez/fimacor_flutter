import 'package:flutter/material.dart';

/// Tipo de campo de un catalogo: texto libre o una referencia (llave
/// foranea) a otro catalogo, que se muestra como dropdown resuelto por
/// nombre en vez de pedirle al usuario un id a mano.
enum CatalogFieldType { texto, referencia }

class CatalogFieldConfig {
  const CatalogFieldConfig({
    required this.key,
    required this.label,
    this.type = CatalogFieldType.texto,
    this.referenciaCatalogo,
  });

  /// Nombre exacto de la columna, tal como lo espera el servidor.
  final String key;
  final String label;
  final CatalogFieldType type;

  /// Clave de CatalogTypeConfig.key al que apunta esta referencia
  /// (ej. Marca_idMarca -> 'marca').
  final String? referenciaCatalogo;
}

class CatalogTypeConfig {
  const CatalogTypeConfig({
    required this.key,
    required this.titulo,
    required this.icon,
    required this.campos,
  });

  final String key;
  final String titulo;
  final IconData icon;
  final List<CatalogFieldConfig> campos;

  /// Campo usado como "nombre" principal para mostrar cada fila en la
  /// lista y como etiqueta cuando este catalogo es referenciado por otro.
  CatalogFieldConfig get campoPrincipal => campos.first;
}

/// Los 7 catalogos que alimentan Maquinas y Mantenimiento (equivalente
/// movil de Configuracion.jsp, acotado a lo que necesita el resto del
/// panel de Administrador).
final List<CatalogTypeConfig> kCatalogTypes = [
  const CatalogTypeConfig(
    key: 'sedes',
    titulo: 'Sedes',
    icon: Icons.location_city_outlined,
    campos: [CatalogFieldConfig(key: 'nombre_sede', label: 'Nombre de la sede')],
  ),
  const CatalogTypeConfig(
    key: 'marca',
    titulo: 'Marcas',
    icon: Icons.sell_outlined,
    campos: [CatalogFieldConfig(key: 'descripcion_marca', label: 'Nombre de la marca')],
  ),
  const CatalogTypeConfig(
    key: 'modelo',
    titulo: 'Modelos',
    icon: Icons.widgets_outlined,
    campos: [
      CatalogFieldConfig(key: 'descripcion_modelo', label: 'Nombre del modelo'),
      CatalogFieldConfig(
        key: 'Marca_idMarca',
        label: 'Marca',
        type: CatalogFieldType.referencia,
        referenciaCatalogo: 'marca',
      ),
    ],
  ),
  const CatalogTypeConfig(
    key: 'tipo-maquina',
    titulo: 'Tipos de maquina',
    icon: Icons.category_outlined,
    campos: [CatalogFieldConfig(key: 'descripcion_maquina', label: 'Nombre del tipo')],
  ),
  const CatalogTypeConfig(
    key: 'estado-maquina',
    titulo: 'Estados de maquina',
    icon: Icons.flag_outlined,
    campos: [
      CatalogFieldConfig(key: 'nombre_tipo', label: 'Nombre corto'),
      CatalogFieldConfig(key: 'descripcion_estado', label: 'Descripcion'),
    ],
  ),
  const CatalogTypeConfig(
    key: 'ambientes',
    titulo: 'Ambientes',
    icon: Icons.meeting_room_outlined,
    campos: [
      CatalogFieldConfig(key: 'descripcion_ambiente', label: 'Nombre del ambiente'),
      CatalogFieldConfig(
        key: 'Sede_idSede',
        label: 'Sede',
        type: CatalogFieldType.referencia,
        referenciaCatalogo: 'sedes',
      ),
    ],
  ),
  const CatalogTypeConfig(
    key: 'tipo-mantenimiento',
    titulo: 'Tipos de mantenimiento',
    icon: Icons.build_circle_outlined,
    campos: [CatalogFieldConfig(key: 'descripcion_matenimiento', label: 'Nombre del tipo')],
  ),
];
