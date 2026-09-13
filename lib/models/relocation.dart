import 'admin_machine.dart';
import 'json_helpers.dart';

/// Catalogos necesarios para armar el formulario de solicitud de
/// reubicacion: maquinas, sedes y ambientes (destino).
class RelocationCatalogs {
  const RelocationCatalogs({
    required this.maquinas,
    required this.sedes,
    required this.ambientes,
  });

  final List<CatalogItem> maquinas;
  final List<CatalogItem> sedes;
  final List<CatalogItem> ambientes;

  factory RelocationCatalogs.fromJson(Map<String, dynamic> json) {
    List<CatalogItem> items(String key) => ((json[key] as List?) ?? [])
        .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return RelocationCatalogs(
      maquinas: items('maquinas'),
      sedes: items('sedes'),
      ambientes: items('ambientes'),
    );
  }
}

/// Solicitud de reubicacion de maquina (equivalente movil de una fila de
/// Reubicacion_maquina.jsp / la autorizacion en Menu.jsp).
class RelocationRequest {
  const RelocationRequest({
    required this.idReubicacion,
    required this.maquina,
    required this.tipoTraslado,
    required this.origen,
    required this.destino,
    required this.areaDestino,
    required this.fecha,
    required this.descripcion,
    required this.observacion,
    required this.estado,
    required this.respuesta,
    required this.evidenciaUrl,
  });

  final int idReubicacion;
  final String maquina;
  final String tipoTraslado;
  final String origen;
  final String destino;
  final String areaDestino;
  final String fecha;
  final String descripcion;
  final String observacion;
  final String estado;
  final String respuesta;
  final String evidenciaUrl;

  bool get pendiente => estado.toLowerCase() == 'pendiente';
  bool get aprobada => estado.toLowerCase() == 'aprobado';

  factory RelocationRequest.fromJson(Map<String, dynamic> json) {
    return RelocationRequest(
      idReubicacion: asInt(json['idReubicacion']),
      maquina: (json['maquina'] ?? '').toString(),
      tipoTraslado: (json['tipoTraslado'] ?? '').toString(),
      origen: (json['origen'] ?? '').toString(),
      destino: (json['destino'] ?? '').toString(),
      areaDestino: (json['areaDestino'] ?? '').toString(),
      fecha: (json['fecha'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      observacion: (json['observacion'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      respuesta: (json['respuesta'] ?? '').toString(),
      evidenciaUrl: (json['evidenciaUrl'] ?? '').toString(),
    );
  }
}
