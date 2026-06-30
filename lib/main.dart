import 'package:flutter/material.dart';
import 'theme/fimacor_theme.dart';
import 'screens/login_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/recuperar_screen.dart';
import 'data/fake_data.dart';
void main() {
  runApp(const FimacorApp());
}

class FimacorApp extends StatelessWidget {
  const FimacorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FIMACOR',
      theme: FimacorTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/menu': (context) => const MenuScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/recuperar': (context) => const RecuperarScreen(),
      },
    );
  }
}