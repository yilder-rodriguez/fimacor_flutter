class RegisterResult {
  const RegisterResult({required this.ok, this.field, this.message});

  final bool ok;
  final String? field;
  final String? message;

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      ok: json['ok'] == true,
      field: (json['campo'] as String?),
      message: (json['mensaje'] as String?),
    );
  }
}

/// Resultado del analisis del carnet SENA (foto) via AnalizarCarnetServlet.
class CarnetAnalysisResult {
  const CarnetAnalysisResult({
    required this.ok,
    this.documento,
    this.rol,
    this.message,
  });

  final bool ok;
  final String? documento;
  final String? rol;
  final String? message;

  factory CarnetAnalysisResult.fromJson(Map<String, dynamic> json) {
    return CarnetAnalysisResult(
      ok: json['ok'] == true,
      documento: (json['documento'] as String?),
      rol: (json['rol'] as String?),
      message: (json['mensaje'] as String?),
    );
  }
}
