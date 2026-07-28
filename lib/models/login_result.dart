class LoginResult {
  const LoginResult({required this.ok, this.message, this.userId, this.role});

  final bool ok;
  final String? message;
  final int? userId;
  final String? role;
}
