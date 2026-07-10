class LoginResult {
  const LoginResult({required this.ok, this.message, this.userId});

  final bool ok;
  final String? message;
  final int? userId;
}
