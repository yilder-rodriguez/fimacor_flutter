import 'json_helpers.dart';

class ManualItem {
  ManualItem({
    required this.id,
    required this.title,
    required this.type,
    required this.machineCode,
    required this.openUrl,
    required this.downloadUrl,
  });

  final int id;
  final String title;
  final String type;
  final String machineCode;
  final String openUrl;
  final String downloadUrl;

  factory ManualItem.fromJson(Map<String, dynamic> json) {
    return ManualItem(
      id: asInt(json['idManual'] ?? json['id']),
      title: (json['titulo'] ?? json['nombre'] ?? 'Manual').toString(),
      type: (json['tipo'] ?? '').toString(),
      machineCode: (json['codigoSena'] ?? json['codigo_sena'] ?? '').toString(),
      openUrl: (json['abrirUrl'] ?? json['url'] ?? '').toString(),
      downloadUrl: (json['descargarUrl'] ?? json['downloadUrl'] ?? '').toString(),
    );
  }
}