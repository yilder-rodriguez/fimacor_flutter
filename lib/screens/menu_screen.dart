import 'package:flutter/material.dart';
import '../widgets/fimacor_widgets.dart';
import '../theme/fimacor_theme.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FimacorNavBar(
        userInitials: 'AD',
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/');
        },
      ),
      backgroundColor: FimacorColors.fondoFormulario,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _card(Icons.build, 'Mantenimientos'),
            _card(Icons.precision_manufacturing, 'Maquinaria'),
            _card(Icons.people, 'Usuarios'),
            _card(Icons.bar_chart, 'Reportes'),
          ],
        ),
      ),
    );
  }

  Widget _card(IconData icon, String titulo) {
    return Card(
      elevation: 3,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 60,
              color: FimacorColors.primario,
            ),
            const SizedBox(height: 15),
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}