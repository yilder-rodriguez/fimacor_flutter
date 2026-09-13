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
