import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  runApp(const FimacorApp());
}

class FimacorApp extends StatelessWidget {
  const FimacorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIMACOR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
