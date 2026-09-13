import 'json_helpers.dart';

/// Item generico de catalogo ({id, nombre}) usado para sedes, marcas,
/// tipos, ambientes y estados en los combos del formulario de maquina.
class CatalogItem {
  const CatalogItem({required this.id, required this.nombre});

  final int id;
  final String nombre;

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(id: asInt(json['id']), nombre: (json['nombre'] ?? '').toString());
  }
}

/// Modelo de maquina: igual que CatalogItem pero ademas sabe a que
/// marca pertenece, para filtrar el combo de modelos segun la marca
/// elegida (misma regla que valida el servidor).
class ModeloItem {
  const ModeloItem({required this.id, required this.nombre, required this.idMarca});

  final int id;
  final String nombre;
  final int idMarca;

  factory ModeloItem.fromJson(Map<String, dynamic> json) {
    return ModeloItem(
      id: asInt(json['id']),
      nombre: (json['nombre'] ?? '').toString(),
      idMarca: asInt(json['idMarca']),
    );
  }
}

/// Catalogos completos para armar el formulario de alta/edicion de maquina.
class MachineCatalogs {
  const MachineCatalogs({
    required this.sedes,
    required this.marcas,
    required this.modelos,
    required this.tipos,
    required this.ambientes,
    required this.estados,
  });

  final List<CatalogItem> sedes;
  final List<CatalogItem> marcas;
  final List<ModeloItem> modelos;
  final List<CatalogItem> tipos;
  final List<CatalogItem> ambientes;
  final List<CatalogItem> estados;

  factory MachineCatalogs.fromJson(Map<String, dynamic> json) {
    List<CatalogItem> items(String key) => ((json[key] as List?) ?? [])
        .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return MachineCatalogs(
      sedes: items('sedes'),
      marcas: items('marcas'),
      modelos: ((json['modelos'] as List?) ?? [])
          .map((e) => ModeloItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      tipos: items('tipos'),
      ambientes: items('ambientes'),
      estados: items('estados'),
    );
  }
}

/// Ficha de maquina tal como la ve el Administrador (equivalente movil
/// de una fila de Maquinas_registradas.jsp, ya con los nombres de
/// catalogo resueltos por el servidor).
class AdminMachine {
  const AdminMachine({
    required this.idMaquina,
    required this.codigoSena,
    required this.descripcion,
    required this.idMarca,
    required this.marca,
    required this.idModelo,
    required this.modelo,
    required this.idTipo,
    required this.tipo,
    required this.idAmbiente,
    required this.ambiente,
    required this.idSede,
    required this.sede,
    required this.area,
    required this.idEstado,
    required this.estado,
    required this.fechaCompra,
    required this.valorMaquina,
    required this.tieneGarantia,
    required this.fechaGarantia,
  });

  final int idMaquina;
  final String codigoSena;
  final String descripcion;
  final int idMarca;
  final String marca;
  final int idModelo;
  final String modelo;
  final int idTipo;
  final String tipo;
  final int idAmbiente;
  final String ambiente;
  final int idSede;
  final String sede;
  final String area;
  final int idEstado;
  final String estado;
  final String fechaCompra;
  final String valorMaquina;
  final bool tieneGarantia;
  final String fechaGarantia;

  factory AdminMachine.fromJson(Map<String, dynamic> json) {
    return AdminMachine(
      idMaquina: asInt(json['idMaquina']),
      codigoSena: (json['codigoSena'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      idMarca: asInt(json['idMarca']),
      marca: (json['marca'] ?? '').toString(),
      idModelo: asInt(json['idModelo']),
      modelo: (json['modelo'] ?? '').toString(),
      idTipo: asInt(json['idTipo']),
      tipo: (json['tipo'] ?? '').toString(),
      idAmbiente: asInt(json['idAmbiente']),
      ambiente: (json['ambiente'] ?? '').toString(),
      idSede: asInt(json['idSede']),
      sede: (json['sede'] ?? '').toString(),
      area: (json['area'] ?? '').toString(),
      idEstado: asInt(json['idEstado']),
      estado: (json['estado'] ?? '').toString(),
      fechaCompra: (json['fechaCompra'] ?? '').toString(),
      valorMaquina: (json['valorMaquina'] ?? '').toString(),
      tieneGarantia: json['tieneGarantia'] == true,
      fechaGarantia: (json['fechaGarantia'] ?? '').toString(),
    );
  }
}
