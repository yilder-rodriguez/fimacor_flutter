import 'json_helpers.dart';

class Machine {
  Machine({
    required this.id,
    required this.code,
    required this.description,
    required this.brand,
    required this.model,
    required this.status,
    required this.location,
    this.sede,
    this.area,
    this.ambiente,
  });

  final int id;
  final String code;
  final String description;
  final String brand;
  final String model;
  final String status;
  final String location;
  final String? sede;
  final String? area;
  final String? ambiente;

  factory Machine.fromJson(Map<String, dynamic> json) {
    String? pickValue(Map<String, dynamic> source, List<String> keys) {
      for (final key in keys) {
        final value = source[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
        if (value is num) return value.toString();
        if (value is Map) {
          final nested = pickValue(Map<String, dynamic>.from(value), [
            'nombre',
            'value',
            'valor',
            'descripcion',
            'numero',
            'text',
            'texto',
            'id',
          ]);
          if (nested != null) return nested;
        }
      }
      return null;
    }

    final loc = (json['ubicacion'] ?? json['ambiente'] ?? '').toString();
    final parts = loc
        .split(RegExp(r'[-/|]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    String? sede = pickValue(json, [
      'sede',
      'sede_nombre',
      'sedeName',
      'sedeNombre',
      'sedePrincipal',
      'sede_principal',
      'nombreSede',
      'nombre_sede',
      'sedeId',
      'sede_id',
    ]);
    String? area = pickValue(json, [
      'area',
      'area_nombre',
      'areaName',
      'areaNombre',
      'areaPrincipal',
      'area_principal',
      'nombreArea',
      'nombre_area',
      'areaId',
      'area_id',
    ]);
    String? ambiente = pickValue(json, [
      'ambiente',
      'ambiente_nombre',
      'ambienteName',
      'ambienteNombre',
      'numeroAmbiente',
      'numero_ambiente',
      'ambienteNumero',
      'ambiente_numero',
      'numAmbiente',
      'num_ambiente',
      'nombreAmbiente',
      'nombre_ambiente',
      'codigoAmbiente',
      'codigo_ambiente',
      'ambienteId',
      'ambiente_id',
      'idAmbiente',
      'id_ambiente',
      'numero',
    ]);

    if ((sede == null || sede.trim().isEmpty) && parts.isNotEmpty) {
      sede = parts[0];
    }
    if ((area == null || area.trim().isEmpty) && parts.length > 1) {
      area = parts[1];
    }
    if ((ambiente == null || ambiente.trim().isEmpty) && parts.length > 2) {
      ambiente = parts[2];
    }

    final locationParts = <String?>[sede, area, ambiente]
        .where((value) => value != null && value.trim().isNotEmpty)
        .toList();
    final displayLocation = locationParts.isNotEmpty
        ? locationParts.join(' - ')
        : loc;

    return Machine(
      id: asInt(json['idMaquina'] ?? json['id']),
      code: (json['codigoSena'] ?? json['codigo_sena'] ?? '').toString(),
      description: (json['descripcion'] ?? 'Maquina asignada').toString(),
      brand: (json['marca'] ?? '').toString(),
      model: (json['modelo'] ?? '').toString(),
      status: (json['estado'] ?? '').toString(),
      location: displayLocation,
      sede: sede,
      area: area,
      ambiente: ambiente,
    );
  }
}
